import '../../domain/entities/chain.dart';
import '../../domain/entities/chain_progress.dart';
import '../../domain/entities/chain_stage.dart';

/// A [Chain] bundled with its derived progress view — precomputed by
/// `chain_query_providers.dart` via `ChainProgressPolicy` so widgets never
/// call the policy or compare stage indices themselves (Phase 11: "Avoid
/// raw indexes inside widgets").
class ChainWithProgress {
  final Chain chain;
  final ChainProgress progress;
  final List<ChainStage> stages;
  final double completionPercent;

  /// The active stage to work on next — `null` once [isCompleted].
  final ChainStage? currentStage;
  final bool isCompleted;

  /// Whether [Chain.hiddenUntilStarted] should still mask this chain's
  /// title/description — `true` only once at least one stage has
  /// completed.
  final bool hasStarted;

  const ChainWithProgress({
    required this.chain,
    required this.progress,
    required this.stages,
    required this.completionPercent,
    required this.currentStage,
    required this.isCompleted,
    required this.hasStarted,
  });

  @override
  bool operator ==(Object other) =>
      other is ChainWithProgress &&
      other.chain == chain &&
      other.progress == progress &&
      other.completionPercent == completionPercent &&
      other.currentStage == currentStage &&
      other.isCompleted == isCompleted &&
      other.hasStarted == hasStarted;

  @override
  int get hashCode => Object.hash(
    chain,
    progress,
    completionPercent,
    currentStage,
    isCompleted,
    hasStarted,
  );
}
