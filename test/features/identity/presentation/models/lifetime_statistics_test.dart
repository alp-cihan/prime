import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/identity/domain/entities/identity_snapshot.dart';
import 'package:prime/features/identity/presentation/models/lifetime_statistics.dart';

void main() {
  test('fromSnapshot projects the four lifetime counters unchanged', () {
    const snapshot = IdentitySnapshot(
      currentLevel: 4,
      lifetimeXp: 500,
      xpIntoCurrentLevel: 20,
      xpNeededForNextLevel: 300,
      attributeXp: {},
      completedQuests: 12,
      completedChains: 2,
      unlockedAchievements: 3,
      currentStreakDays: 5,
    );

    final statistics = LifetimeStatistics.fromSnapshot(snapshot);

    expect(statistics.completedQuests, 12);
    expect(statistics.completedChains, 2);
    expect(statistics.unlockedAchievements, 3);
    expect(statistics.totalXpEarned, 500);
  });

  test('equal statistics compare equal', () {
    const a = LifetimeStatistics(
      completedQuests: 1,
      completedChains: 1,
      unlockedAchievements: 1,
      totalXpEarned: 100,
    );
    const b = LifetimeStatistics(
      completedQuests: 1,
      completedChains: 1,
      unlockedAchievements: 1,
      totalXpEarned: 100,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
