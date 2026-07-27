/// Where one [Chain] stage stands relative to the player's progress —
/// derived fresh by `ChainProgressPolicy`, never persisted itself (only the
/// underlying [ChainProgress.completedStageCount] is).
enum ChainStageStatus { locked, unlocked, completed }

/// One stage of a [Chain] — its quest id, position, and current status.
/// Widgets render a `List<ChainStage>` instead of comparing raw indices
/// themselves (Phase 11: "Avoid raw indexes inside widgets").
class ChainStage {
  final String questId;
  final int index;
  final ChainStageStatus status;

  const ChainStage({
    required this.questId,
    required this.index,
    required this.status,
  });

  @override
  bool operator ==(Object other) =>
      other is ChainStage &&
      other.questId == questId &&
      other.index == index &&
      other.status == status;

  @override
  int get hashCode => Object.hash(questId, index, status);
}
