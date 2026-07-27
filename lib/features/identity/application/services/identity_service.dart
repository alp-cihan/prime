import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/persistence/hive_keys.dart';
import '../../../achievements/domain/catalog/achievement_catalog.dart';
import '../../../achievements/domain/entities/achievement.dart';
import '../../../achievements/domain/repositories/achievement_unlock_repository.dart';
import '../../../chains/domain/catalog/chain_catalog.dart';
import '../../../chains/domain/entities/chain.dart';
import '../../../chains/domain/repositories/chain_progress_repository.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../../xp_ledger/domain/services/level_curve.dart';
import '../../domain/entities/identity_milestone.dart';
import '../../domain/entities/identity_snapshot.dart';

/// docs/architecture.md §4.1 — the global player level uses `base: 100`,
/// matching every other feature that independently derives it from the
/// same pure [LevelCurve] (`player_level_providers.dart`,
/// `achievement_evaluation_service.dart`).
const _playerLevelBase = 100;

/// Assembles [IdentitySnapshot]/[IdentityMilestone]s entirely from
/// existing repositories — the XP ledger, achievement unlocks, and chain
/// progress — plus the code-based achievement/chain catalogs for titles
/// and icon keys. Introduces no persistence of its own (Phase 12: "Do not
/// introduce duplicated persistence"); every number is recomputed on every
/// call, so a restart that preserves the underlying ledger/unlock/progress
/// data automatically preserves identical results here too.
///
/// ## Two different "dates" from the same ledger row, on purpose
/// [XpTransaction.createdAt] is the literal wall-clock instant a
/// transaction was recorded (via `Clock.now()` at write time) — used here
/// for [IdentitySnapshot.firstQuestDate]/[IdentitySnapshot.latestActivityDate],
/// since those ask "when did this really happen". A transaction's
/// `sourceId` instead embeds the *occurrence anchor* date (Phase 9) — for a
/// `weekly` repeatable quest that can be its ISO week's Monday, not the
/// literal day a specific completion happened on. [currentStreakDays] uses
/// that occurrence-anchor date instead, for exact consistency with
/// `AchievementEvaluationService`'s identical `longestConsecutiveCompletionDayStreak`
/// derivation (Phase 10) — both features agree on what "a day with a
/// completion" means, they just answer different questions about the same
/// day-set (longest-ever run vs. the run ending today/yesterday).
///
/// ## Not the forgiveness-token streak system
/// [IdentitySnapshot.currentStreakDays] is a simple, fully-derived
/// "consecutive days with a completion, ending today or yesterday" count —
/// it is not docs/architecture.md §11's forgiveness-token/Recovery Quest
/// system (protected misses, comeback XP, lifetime consistency score),
/// which nothing in this app implements yet. This is the "(derived if
/// available)" reading the Phase 12 brief asks for: a straightforward
/// ledger derivation, not a dependency on an unbuilt system.
class IdentityService {
  const IdentityService({
    required XpLedgerRepository xpLedgerRepository,
    required AchievementUnlockRepository achievementUnlockRepository,
    required ChainProgressRepository chainProgressRepository,
    List<Achievement> achievements = achievementCatalog,
    List<Chain> chains = chainCatalog,
    LevelCurve levelCurve = const LevelCurve(),
    Clock clock = const SystemClock(),
  }) : _xpLedgerRepository = xpLedgerRepository,
       _achievementUnlockRepository = achievementUnlockRepository,
       _chainProgressRepository = chainProgressRepository,
       _achievementCatalog = achievements,
       _chainCatalog = chains,
       _levelCurve = levelCurve,
       _clock = clock;

  final XpLedgerRepository _xpLedgerRepository;
  final AchievementUnlockRepository _achievementUnlockRepository;
  final ChainProgressRepository _chainProgressRepository;
  final List<Achievement> _achievementCatalog;
  final List<Chain> _chainCatalog;
  final LevelCurve _levelCurve;
  final Clock _clock;

  Future<IdentitySnapshot> buildSnapshot({DateTime? at}) async {
    final instant = at ?? _clock.now();
    final today = DateTime.utc(instant.year, instant.month, instant.day);

    final allTransactions = await _xpLedgerRepository.getAll();

    final lifetimeXp = allTransactions.fold<int>(
      0,
      (sum, t) => sum + t.finalXp,
    );
    final attributeXp = <AttributeType, int>{};
    DateTime? latestActivityDate;
    for (final t in allTransactions) {
      attributeXp[t.attribute] = (attributeXp[t.attribute] ?? 0) + t.finalXp;
      final day = _dateOf(t.createdAt);
      if (latestActivityDate == null || day.isAfter(latestActivityDate)) {
        latestActivityDate = day;
      }
    }
    final levelProgress = _levelCurve.levelForTotalXp(
      lifetimeXp,
      base: _playerLevelBase,
    );

    final questTransactions = allTransactions.where(
      (t) => t.sourceType == XpSourceType.quest,
    );
    final distinctCompletionEvents = <String>{};
    final occurrenceCompletionDays = <DateTime>{};
    DateTime? firstQuestDate;
    for (final t in questTransactions) {
      distinctCompletionEvents.add(t.sourceId);
      final literalDay = _dateOf(t.createdAt);
      if (firstQuestDate == null || literalDay.isBefore(firstQuestDate)) {
        firstQuestDate = literalDay;
      }
      final occurrenceDay = HiveKeys.dateFromSourceId(t.sourceId);
      if (occurrenceDay != null) occurrenceCompletionDays.add(occurrenceDay);
    }

    final chainProgressList = await _chainProgressRepository.getAll();
    final catalogChainIds = _chainCatalog.map((c) => c.id).toSet();
    final completedChains = chainProgressList
        .where(
          (p) => p.completedAt != null && catalogChainIds.contains(p.chainId),
        )
        .length;

    final unlocks = await _achievementUnlockRepository.getAll();
    final catalogAchievementIds = _achievementCatalog.map((a) => a.id).toSet();
    final unlockedAchievements = unlocks
        .where((u) => catalogAchievementIds.contains(u.achievementId))
        .length;

    return IdentitySnapshot(
      currentLevel: levelProgress.level,
      lifetimeXp: lifetimeXp,
      xpIntoCurrentLevel: levelProgress.currentXpIntoLevel,
      xpNeededForNextLevel: levelProgress.xpRequiredForNextLevel,
      attributeXp: attributeXp,
      completedQuests: distinctCompletionEvents.length,
      completedChains: completedChains,
      unlockedAchievements: unlockedAchievements,
      currentStreakDays: _currentStreak(occurrenceCompletionDays, today),
      firstQuestDate: firstQuestDate,
      latestActivityDate: latestActivityDate,
    );
  }

  /// Newest-first, across all three milestone sources — level-ups
  /// (reconstructed from ledger history), achievement unlocks, and chain
  /// completions.
  Future<List<IdentityMilestone>> recentMilestones({int limit = 20}) async {
    final allTransactions = await _xpLedgerRepository.getAll();
    final chronological = List<XpTransaction>.of(allTransactions)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final unlocks = await _achievementUnlockRepository.getAll();
    final achievementById = {for (final a in _achievementCatalog) a.id: a};

    final chainProgressList = await _chainProgressRepository.getAll();
    final chainById = {for (final c in _chainCatalog) c.id: c};

    final milestones = <IdentityMilestone>[
      ..._levelMilestones(chronological),
      for (final unlock in unlocks)
        if (achievementById[unlock.achievementId] case final achievement?)
          IdentityMilestone(
            type: IdentityMilestoneType.achievementUnlocked,
            title: 'Unlocked "${achievement.title}"',
            iconKey: achievement.iconKey,
            occurredAt: unlock.unlockedAt,
          ),
      for (final progress in chainProgressList)
        if (progress.completedAt != null)
          if (chainById[progress.chainId] case final chain?)
            IdentityMilestone(
              type: IdentityMilestoneType.chainCompleted,
              title: 'Completed "${chain.title}"',
              iconKey: chain.iconKey,
              occurredAt: progress.completedAt!,
            ),
    ];

    milestones.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return milestones.take(limit).toList();
  }

  /// Walks the ledger in chronological order, emitting one milestone per
  /// global player level crossed — a single transaction that jumps several
  /// levels at once (a large quest completion) still emits one milestone
  /// per intermediate level, all timestamped at that same transaction.
  List<IdentityMilestone> _levelMilestones(
    List<XpTransaction> chronologicalTransactions,
  ) {
    final milestones = <IdentityMilestone>[];
    var cumulative = 0;
    var lastLevel = 1;
    for (final t in chronologicalTransactions) {
      cumulative += t.finalXp;
      final newLevel = _levelCurve
          .levelForTotalXp(cumulative, base: _playerLevelBase)
          .level;
      if (newLevel > lastLevel) {
        for (var level = lastLevel + 1; level <= newLevel; level++) {
          milestones.add(
            IdentityMilestone(
              type: IdentityMilestoneType.levelReached,
              title: 'Reached Level $level',
              iconKey: 'star',
              occurredAt: t.createdAt,
            ),
          );
        }
        lastLevel = newLevel;
      }
    }
    return milestones;
  }

  /// Consecutive days in [completionDays] ending at [today] or, if today
  /// has no completion yet, at yesterday (the streak is still "alive"
  /// until a full day passes with none) — `0` if neither has one.
  int _currentStreak(Set<DateTime> completionDays, DateTime today) {
    if (completionDays.isEmpty) return 0;

    var cursor = today;
    if (!completionDays.contains(cursor)) {
      cursor = today.subtract(const Duration(days: 1));
      if (!completionDays.contains(cursor)) return 0;
    }

    var streak = 0;
    while (completionDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  DateTime _dateOf(DateTime instant) =>
      DateTime.utc(instant.year, instant.month, instant.day);
}
