import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_unlock.dart';
import '../../domain/repositories/achievement_unlock_repository.dart';
import '../services/achievement_evaluation_service.dart';

/// Evaluates every locked achievement and unlocks whichever are now
/// eligible — the achievements feature's single write path, called after
/// quest completion (see `AchievementEvaluationController`) and once at app
/// start (to retroactively unlock anything an existing account already
/// qualifies for, e.g. after this catalog gains a new entry in a later
/// release).
///
/// ## Ordering: ledger write before unlock write
/// For each achievement being unlocked, its reward `XpTransaction` (if any)
/// is appended *before* the corresponding `AchievementUnlock` record —
/// mirroring `CompleteQuestUseCase`'s exact rationale. If the process is
/// interrupted between the two writes, the achievement is *not yet* marked
/// unlocked, so the next evaluation pass will try again — appending the same
/// reward transaction is a safe no-op (idempotency-key dedup in
/// `XpLedgerRepository.appendAll`), and the unlock record then gets written.
/// Reward XP can therefore never be silently lost, and "restart never
/// causes duplicate unlocks" holds regardless of exactly when a crash
/// happens.
///
/// ## Cascades are safe and bounded
/// A reward payout can itself push the player past another achievement's
/// threshold. This is handled by re-evaluating after each batch, bounded by
/// the catalog's size (each achievement can unlock at most once, so at most
/// one full catalog's worth of passes is ever needed) — this is what
/// guarantees "achievement reward XP must not recursively trigger duplicate
/// unlocks": duplicates are impossible (each id is gated by the unlock
/// repository), and the loop provably terminates.
class EvaluateAndUnlockAchievementsUseCase {
  const EvaluateAndUnlockAchievementsUseCase({
    required AchievementEvaluationService evaluationService,
    required AchievementUnlockRepository unlockRepository,
    required XpLedgerRepository xpLedgerRepository,
    Clock clock = const SystemClock(),
  }) : _evaluationService = evaluationService,
       _unlockRepository = unlockRepository,
       _xpLedgerRepository = xpLedgerRepository,
       _clock = clock;

  final AchievementEvaluationService _evaluationService;
  final AchievementUnlockRepository _unlockRepository;
  final XpLedgerRepository _xpLedgerRepository;
  final Clock _clock;

  Future<Result<List<Achievement>>> execute({int? maxPasses}) async {
    final unlocked = <Achievement>[];
    try {
      final bound = maxPasses ?? _evaluationService.catalogLength;
      for (var pass = 0; pass < bound; pass++) {
        final eligible = await _evaluationService.evaluateEligible();
        if (eligible.isEmpty) break;

        await _unlockBatch(eligible);
        unlocked.addAll(eligible);
      }
    } catch (e) {
      return Err(UnexpectedFailure('Failed to evaluate achievements: $e'));
    }
    return Ok(unlocked);
  }

  Future<void> _unlockBatch(List<Achievement> eligible) async {
    final now = _clock.now();

    final transactions = [
      for (final achievement in eligible)
        if (achievement.rewardXp > 0) _rewardTransaction(achievement, now),
    ];
    if (transactions.isNotEmpty) {
      await _xpLedgerRepository.appendAll(transactions);
    }

    final unlocks = [
      for (final achievement in eligible)
        AchievementUnlock(
          achievementId: achievement.id,
          unlockedAt: now,
          rewardIdempotencyKey: achievement.rewardXp > 0
              ? _rewardIdempotencyKey(achievement.id)
              : null,
        ),
    ];
    await _unlockRepository.appendAll(unlocks);
  }

  /// Achievement rewards aren't earned "into" a specific attribute the way
  /// quest completions are — [Achievement.attributeType] only exists to
  /// describe an `attributeXpReached` *criterion*, not a reward split. When
  /// present, crediting the reward to that same attribute is a natural,
  /// thematically-consistent choice (the achievement is literally about that
  /// attribute); otherwise it defaults to [AttributeType.discipline], the
  /// architecture's own precedent for a "meta"/consistency-flavored
  /// attribute (docs/architecture.md §8's "Iron Mind" example keys off
  /// Discipline for exactly this kind of non-activity-specific reward).
  XpTransaction _rewardTransaction(Achievement achievement, DateTime now) {
    final key = _rewardIdempotencyKey(achievement.id);
    return XpTransaction(
      id: key,
      sourceType: XpSourceType.achievement,
      sourceId: key,
      attribute: achievement.attributeType ?? AttributeType.discipline,
      baseXp: achievement.rewardXp,
      modifiersApplied: const {},
      finalXp: achievement.rewardXp,
      createdAt: now,
      idempotencyKey: key,
    );
  }

  String _rewardIdempotencyKey(String achievementId) => '$achievementId|reward';
}
