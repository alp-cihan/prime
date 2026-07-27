import '../../domain/entities/achievement.dart';

/// A locked [Achievement] paired with current progress toward it (`0.0`-
/// `1.0`, via `AchievementEvaluationPolicy.progressRatio`) — the locked
/// section's row model.
class LockedAchievementProgress {
  final Achievement achievement;
  final double progressRatio;

  const LockedAchievementProgress({
    required this.achievement,
    required this.progressRatio,
  });

  @override
  bool operator ==(Object other) =>
      other is LockedAchievementProgress &&
      other.achievement == achievement &&
      other.progressRatio == progressRatio;

  @override
  int get hashCode => Object.hash(achievement, progressRatio);
}
