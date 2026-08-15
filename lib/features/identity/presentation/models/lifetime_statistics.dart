import '../../domain/entities/identity_snapshot.dart';

/// A thin projection of [IdentitySnapshot]'s lifetime counters — the
/// Identity page's "Lifetime" section reads this instead of picking
/// individual fields off the snapshot itself, giving that section one
/// clearly-named model instead of four loose numbers.
class LifetimeStatistics {
  final int completedQuests;
  final int completedChains;
  final int unlockedAchievements;
  final int totalXpEarned;
  final int currentStreakDays;

  const LifetimeStatistics({
    required this.completedQuests,
    required this.completedChains,
    required this.unlockedAchievements,
    required this.totalXpEarned,
    required this.currentStreakDays,
  });

  factory LifetimeStatistics.fromSnapshot(IdentitySnapshot snapshot) {
    return LifetimeStatistics(
      completedQuests: snapshot.completedQuests,
      completedChains: snapshot.completedChains,
      unlockedAchievements: snapshot.unlockedAchievements,
      totalXpEarned: snapshot.lifetimeXp,
      currentStreakDays: snapshot.currentStreakDays,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LifetimeStatistics &&
      other.completedQuests == completedQuests &&
      other.completedChains == completedChains &&
      other.unlockedAchievements == unlockedAchievements &&
      other.totalXpEarned == totalXpEarned &&
      other.currentStreakDays == currentStreakDays;

  @override
  int get hashCode => Object.hash(
    completedQuests,
    completedChains,
    unlockedAchievements,
    totalXpEarned,
    currentStreakDays,
  );
}
