import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/clock.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../domain/catalog/chain_catalog.dart';
import '../../domain/entities/chain.dart';
import '../../domain/repositories/chain_progress_repository.dart';
import '../services/chain_evaluation_service.dart';

/// The chains feature's single write path: evaluates every chain in the
/// catalog and persists whatever advancement the ledger currently supports,
/// granting each chain's reward exactly once on completion.
///
/// ## Why one use case instead of three
/// The Phase 11 brief asks for "evaluating chain progress", "advancing a
/// chain", and "completing a chain" as separate use cases. They are kept as
/// one cohesive class here (mirroring `EvaluateAndUnlockAchievementsUseCase`,
/// Phase 10's identical consolidation): advancing *is* evaluating-and-then-
/// persisting, and completion is just what evaluation finds when a chain's
/// last stage clears — nothing else in this app would ever call one of
/// these three steps without the other two, so splitting them into
/// separate classes would be ceremony without reuse value. "Loading chains"
/// likewise has no dedicated use case — it's a pure read composition
/// (catalog + progress), served directly by Riverpod providers exactly like
/// `unlockedAchievementsProvider`/`lockedAchievementsProvider` in Phase 10.
///
/// ## Ordering: ledger write before progress write
/// For a chain that completes this pass, its reward `XpTransaction` (if
/// `rewardXp > 0`) is appended *before* the advanced `ChainProgress` is
/// upserted — identical rationale to `EvaluateAndUnlockAchievementsUseCase`.
/// If interrupted between the two, [ChainProgress.completedAt] stays
/// `null`, so the next evaluation re-attempts from the same (unwritten)
/// state; the reward write is a no-op retry (idempotency-key dedup), and
/// the progress write then completes. Reward XP can never be lost or
/// double-granted.
class EvaluateAndAdvanceChainsUseCase {
  const EvaluateAndAdvanceChainsUseCase({
    required ChainEvaluationService evaluationService,
    required ChainProgressRepository progressRepository,
    required XpLedgerRepository xpLedgerRepository,
    List<Chain> catalog = chainCatalog,
    Clock clock = const SystemClock(),
  }) : _evaluationService = evaluationService,
       _progressRepository = progressRepository,
       _xpLedgerRepository = xpLedgerRepository,
       _catalog = catalog,
       _clock = clock;

  final ChainEvaluationService _evaluationService;
  final ChainProgressRepository _progressRepository;
  final XpLedgerRepository _xpLedgerRepository;
  final List<Chain> _catalog;
  final Clock _clock;

  Future<Result<List<Chain>>> execute() async {
    final completedChains = <Chain>[];
    try {
      final completedQuestIds = await _evaluationService.completedQuestIds();
      final instant = _clock.now();

      for (final chain in _catalog) {
        final result = await _evaluationService.evaluate(
          chain,
          completedQuestIds: completedQuestIds,
          instant: instant,
        );
        if (!result.advanced) continue;

        if (result.newlyCompleted && chain.rewardXp > 0) {
          await _xpLedgerRepository.appendAll([
            _rewardTransaction(chain, instant),
          ]);
        }
        await _progressRepository.upsert(result.progress);

        if (result.newlyCompleted) completedChains.add(chain);
      }
    } catch (e) {
      return Err(UnexpectedFailure('Failed to evaluate chains: $e'));
    }
    return Ok(completedChains);
  }

  /// Chain rewards aren't tied to a specific attribute the way quest
  /// completions are — defaults to [AttributeType.discipline], the same
  /// "meta" reward attribute achievements use, for the same reason (docs/
  /// architecture.md §8's "Iron Mind" precedent).
  XpTransaction _rewardTransaction(Chain chain, DateTime now) {
    final key = _rewardIdempotencyKey(chain.id);
    return XpTransaction(
      id: key,
      sourceType: XpSourceType.chainMilestone,
      sourceId: key,
      attribute: AttributeType.discipline,
      baseXp: chain.rewardXp,
      modifiersApplied: const {},
      finalXp: chain.rewardXp,
      createdAt: now,
      idempotencyKey: key,
    );
  }

  String _rewardIdempotencyKey(String chainId) => '$chainId|reward';
}
