import '../../domain/entities/achievement.dart';

/// An [Achievement] paired with the fact and date it was unlocked — the
/// unlocked section's row model. Deliberately doesn't carry the raw
/// [AchievementUnlock] itself: the UI only ever needs [unlockedAt] from it.
class UnlockedAchievement {
  final Achievement achievement;
  final DateTime unlockedAt;

  const UnlockedAchievement({
    required this.achievement,
    required this.unlockedAt,
  });

  @override
  bool operator ==(Object other) =>
      other is UnlockedAchievement &&
      other.achievement == achievement &&
      other.unlockedAt == unlockedAt;

  @override
  int get hashCode => Object.hash(achievement, unlockedAt);
}
