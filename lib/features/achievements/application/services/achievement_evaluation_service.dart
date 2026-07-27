import '../../../../core/domain/attribute_type.dart';
import '../../../../core/persistence/hive_keys.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../../xp_ledger/domain/services/level_curve.dart';
import '../../domain/catalog/achievement_catalog.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_unlock_repository.dart';
import '../../domain/services/achievement_criteria_snapshot.dart';
import '../../domain/services/achievement_evaluation_policy.dart';

/// docs/architecture.md §4.1 — the global player level uses `base: 100`,
/// matching `player_level_providers.dart`'s own constant (kept in sync by
/// both reading straight from the one pure [LevelCurve], never duplicating
/// the curve's math itself).
const _playerLevelBase = 100;

/// Hard-or-above threshold on `XpTransaction.modifiersApplied['difficulty']`
/// — `QuestDifficulty.hard` resolves to exactly `1.3` in
/// `QuestXpCalculator`'s own multiplier table (`veryHard` is `1.6`), so
/// `>= 1.3` captures both without this feature needing to know about
/// `QuestDifficulty` at all — only the ledger's own recorded modifier.
const _hardOrAboveDifficultyMultiplier = 1.3;

/// Composes [AchievementEvaluationPolicy] with the XP ledger + unlock
/// history to answer "which locked achievements are eligible right now" —
/// the achievements-feature counterpart to the quests feature's
/// `QuestOccurrenceService` (Phase 9): a read-only application service that
/// builds a fresh [AchievementCriteriaSnapshot] from repositories every
/// time, never caching or persisting it.
///
/// ## Why quest-shaped aggregates exclude achievement-reward transactions
/// [XpTransaction.sourceType] distinguishes a real quest completion
/// (`XpSourceType.quest`) from an achievement's own reward payout
/// (`XpSourceType.achievement`, written by
/// `EvaluateAndUnlockAchievementsUseCase`). [totalQuestCompletions],
/// [hardOrAboveCompletionCount], and the consecutive-day streak are all
/// meant to answer "how many quests has the player completed" — counting a
/// reward payout as a quest completion would inflate that number by one
/// for every achievement ever unlocked, and would even fabricate a
/// "completion day" out of thin air. [lifetimeXp]/[xpByAttribute] have no
/// such problem and deliberately include every transaction, matching
/// `XpLedgerRepository.sumLifetimeXp()`/`sumXpForAttribute()`'s own
/// unfiltered behavior (a reward's XP is real XP).
class AchievementEvaluationService {
  const AchievementEvaluationService({
    required XpLedgerRepository xpLedgerRepository,
    required AchievementUnlockRepository unlockRepository,
    List<Achievement> catalog = achievementCatalog,
    AchievementEvaluationPolicy policy = const AchievementEvaluationPolicy(),
    LevelCurve levelCurve = const LevelCurve(),
  }) : _xpLedgerRepository = xpLedgerRepository,
       _unlockRepository = unlockRepository,
       _catalog = catalog,
       _policy = policy,
       _levelCurve = levelCurve;

  final XpLedgerRepository _xpLedgerRepository;
  final AchievementUnlockRepository _unlockRepository;
  final List<Achievement> _catalog;
  final AchievementEvaluationPolicy _policy;
  final LevelCurve _levelCurve;

  /// The catalog's size — an upper bound on how many evaluation passes
  /// `EvaluateAndUnlockAchievementsUseCase` could ever need (each pass
  /// unlocks at least one achievement or the loop stops, and there are only
  /// this many to unlock, ever).
  int get catalogLength => _catalog.length;

  Future<AchievementCriteriaSnapshot> buildSnapshot() async {
    final allTransactions = await _xpLedgerRepository.getAll();

    final lifetimeXp = allTransactions.fold<int>(
      0,
      (sum, t) => sum + t.finalXp,
    );
    final xpByAttribute = <AttributeType, int>{};
    for (final t in allTransactions) {
      xpByAttribute[t.attribute] =
          (xpByAttribute[t.attribute] ?? 0) + t.finalXp;
    }
    final playerLevel = _levelCurve
        .levelForTotalXp(lifetimeXp, base: _playerLevelBase)
        .level;

    final questTransactions = allTransactions.where(
      (t) => t.sourceType == XpSourceType.quest,
    );
    final byCompletionEvent = <String, XpTransaction>{};
    final completionDays = <DateTime>{};
    for (final t in questTransactions) {
      byCompletionEvent.putIfAbsent(t.sourceId, () => t);
      final day = HiveKeys.dateFromSourceId(t.sourceId);
      if (day != null) completionDays.add(day);
    }
    final hardOrAboveCompletionCount = byCompletionEvent.values
        .where(
          (t) =>
              (t.modifiersApplied['difficulty'] ?? 1.0) >=
              _hardOrAboveDifficultyMultiplier,
        )
        .length;

    return AchievementCriteriaSnapshot(
      totalQuestCompletions: byCompletionEvent.length,
      lifetimeXp: lifetimeXp,
      playerLevel: playerLevel,
      xpByAttribute: xpByAttribute,
      hardOrAboveCompletionCount: hardOrAboveCompletionCount,
      longestConsecutiveCompletionDayStreak: _longestConsecutiveDayRun(
        completionDays,
      ),
    );
  }

  /// Achievements from [catalog] that are not yet unlocked but whose
  /// criteria a fresh snapshot satisfies — sorted by [Achievement.sortOrder]
  /// so callers never need to re-sort.
  Future<List<Achievement>> evaluateEligible() async {
    final unlockedIds = (await _unlockRepository.getAll())
        .map((u) => u.achievementId)
        .toSet();
    final snapshot = await buildSnapshot();

    final eligible = [
      for (final achievement in _catalog)
        if (!unlockedIds.contains(achievement.id) &&
            _policy.isSatisfied(achievement, snapshot))
          achievement,
    ];
    eligible.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return eligible;
  }

  /// The longest run of consecutive calendar days present in [days] — `0`
  /// for an empty set, `1` for a single isolated day. [days] must already be
  /// UTC-date-normalized (guaranteed by [HiveKeys.dateFromSourceId]).
  int _longestConsecutiveDayRun(Set<DateTime> days) {
    if (days.isEmpty) return 0;
    final sorted = days.toList()..sort();

    var longest = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gapInDays = sorted[i].difference(sorted[i - 1]).inDays;
      current = gapInDays == 1 ? current + 1 : 1;
      if (current > longest) longest = current;
    }
    return longest;
  }
}
