import '../entities/chain.dart';
import '../entities/chain_progress.dart';
import '../entities/chain_stage.dart';

/// The single authority for everything derived from a [Chain] +
/// [ChainProgress] pair: which stage is current, which are locked/unlocked/
/// completed, whether the chain is finished, and completion percentage.
/// Pure Dart, no repository access — `ChainEvaluationService` (application
/// layer) is what decides *when* a stage should advance (it needs the XP
/// ledger for that); this policy only ever answers questions about a
/// snapshot it's handed.
class ChainProgressPolicy {
  const ChainProgressPolicy();

  /// A fresh chain nobody has touched yet — stage 0 unlocked, nothing
  /// completed.
  ChainProgress initial(String chainId) =>
      ChainProgress(chainId: chainId, completedStageCount: 0);

  bool isCompleted(Chain chain, ChainProgress progress) =>
      progress.completedStageCount >= chain.questIds.length;

  /// Whether the player has made any progress at all — the gate
  /// `Chain.hiddenUntilStarted` checks: a hidden chain reveals its real
  /// title/description the moment its first stage completes, regardless of
  /// how far it's gotten since.
  bool hasStarted(ChainProgress progress) => progress.completedStageCount > 0;

  /// How many stages are currently unlocked (completed + the one active
  /// stage), clamped to the chain's length — the first stage is unlocked
  /// from the start, so this is never `0` for a non-empty chain.
  int unlockedStageCount(Chain chain, ChainProgress progress) {
    if (chain.questIds.isEmpty) return 0;
    return (progress.completedStageCount + 1).clamp(0, chain.questIds.length);
  }

  /// The index of the next incomplete stage, or `null` once the chain is
  /// fully completed (there is no "current" stage to work on anymore).
  int? currentStageIndex(Chain chain, ChainProgress progress) {
    final index = progress.completedStageCount;
    return index < chain.questIds.length ? index : null;
  }

  /// `0.0`-`1.0` — `1.0` for an empty chain (vacuously complete) rather than
  /// dividing by zero.
  double completionPercent(Chain chain, ChainProgress progress) {
    if (chain.questIds.isEmpty) return 1.0;
    return (progress.completedStageCount / chain.questIds.length).clamp(
      0.0,
      1.0,
    );
  }

  /// The full per-stage status breakdown, in chain order — what
  /// `ChainDetailPage` renders directly instead of comparing indices
  /// itself.
  List<ChainStage> stagesFor(Chain chain, ChainProgress progress) {
    return [
      for (var i = 0; i < chain.questIds.length; i++)
        ChainStage(
          questId: chain.questIds[i],
          index: i,
          status: i < progress.completedStageCount
              ? ChainStageStatus.completed
              : i == progress.completedStageCount
              ? ChainStageStatus.unlocked
              : ChainStageStatus.locked,
        ),
    ];
  }

  /// Advances [progress] by exactly one stage, setting [ChainProgress
  /// .completedAt] to [instant] if that was the final stage. A no-op
  /// (returns [progress] unchanged) if the chain is already complete —
  /// callers are expected to check [isCompleted] first via
  /// `ChainEvaluationService`, but this stays safe to call regardless.
  ChainProgress advance(
    Chain chain,
    ChainProgress progress, {
    required DateTime instant,
  }) {
    if (isCompleted(chain, progress)) return progress;
    final nextCount = progress.completedStageCount + 1;
    final justCompleted = nextCount >= chain.questIds.length;
    return ChainProgress(
      chainId: progress.chainId,
      completedStageCount: nextCount,
      completedAt: justCompleted ? instant : null,
    );
  }
}
