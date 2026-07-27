import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../domain/entities/chain.dart';
import '../../domain/entities/chain_progress.dart';
import '../../domain/repositories/chain_progress_repository.dart';
import '../../domain/services/chain_progress_policy.dart';

/// One chain's evaluation outcome — how far it got and whether *this call*
/// was the one that finished it (so the use case knows to grant the reward
/// exactly once).
class ChainEvaluationResult {
  final ChainProgress progress;
  final bool advanced;
  final bool newlyCompleted;

  const ChainEvaluationResult({
    required this.progress,
    required this.advanced,
    required this.newlyCompleted,
  });
}

/// Composes [ChainProgressPolicy] with the XP ledger + progress repository
/// to answer "how far can this chain advance right now" — the chains
/// feature's counterpart to the achievements feature's
/// `AchievementEvaluationService` (Phase 10) and the quests feature's
/// `QuestOccurrenceService` (Phase 9). Read-mostly: [evaluate] computes the
/// result but does not persist it — `EvaluateAndAdvanceChainsUseCase` owns
/// the actual write (and the reward-XP ordering that makes it crash-safe).
class ChainEvaluationService {
  const ChainEvaluationService({
    required XpLedgerRepository xpLedgerRepository,
    required ChainProgressRepository progressRepository,
    ChainProgressPolicy policy = const ChainProgressPolicy(),
  }) : _xpLedgerRepository = xpLedgerRepository,
       _progressRepository = progressRepository,
       _policy = policy;

  final XpLedgerRepository _xpLedgerRepository;
  final ChainProgressRepository _progressRepository;
  final ChainProgressPolicy _policy;

  /// Every quest id with at least one completion recorded in the ledger —
  /// computed once per evaluation pass and shared across every chain being
  /// evaluated, rather than re-scanning the whole ledger per chain per
  /// stage. A quest id never contains `|` (it's a UUID), so the first
  /// `|`-delimited segment of `XpTransaction.sourceId` recovers it exactly,
  /// the same convention `CompleteQuestUseCase` already writes.
  Future<Set<String>> completedQuestIds() async {
    final all = await _xpLedgerRepository.getAll();
    return {
      for (final t in all)
        if (t.sourceType == XpSourceType.quest) t.sourceId.split('|').first,
    };
  }

  Future<ChainProgress> loadOrInitProgress(Chain chain) async {
    return await _progressRepository.getForChain(chain.id) ??
        _policy.initial(chain.id);
  }

  /// Advances [chain] as far as [completedQuestIds] currently allows,
  /// starting from its persisted (or fresh) progress — looping past
  /// several already-satisfied stages in one call if needed (e.g. the
  /// player completed those quests before this chain ever evaluated them,
  /// or before the chain existed at all). A chain already marked
  /// [ChainProgress.completedAt] is never re-evaluated.
  Future<ChainEvaluationResult> evaluate(
    Chain chain, {
    required Set<String> completedQuestIds,
    required DateTime instant,
  }) async {
    var progress = await loadOrInitProgress(chain);
    if (progress.completedAt != null) {
      return ChainEvaluationResult(
        progress: progress,
        advanced: false,
        newlyCompleted: false,
      );
    }

    var advanced = false;
    while (!_policy.isCompleted(chain, progress)) {
      final stageIndex = _policy.currentStageIndex(chain, progress)!;
      final questId = chain.questIds[stageIndex];
      if (!completedQuestIds.contains(questId)) break;
      progress = _policy.advance(chain, progress, instant: instant);
      advanced = true;
    }

    return ChainEvaluationResult(
      progress: progress,
      advanced: advanced,
      newlyCompleted: advanced && progress.completedAt != null,
    );
  }
}
