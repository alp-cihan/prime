import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/identity/domain/entities/identity_snapshot.dart';
import 'package:prime/features/identity/presentation/models/attribute_distribution.dart';

IdentitySnapshot _snapshot(Map<AttributeType, int> attributeXp) {
  return IdentitySnapshot(
    currentLevel: 1,
    lifetimeXp: attributeXp.values.fold<int>(0, (sum, xp) => sum + xp),
    xpIntoCurrentLevel: 0,
    xpNeededForNextLevel: 100,
    attributeXp: attributeXp,
    completedQuests: 0,
    completedChains: 0,
    unlockedAchievements: 0,
    currentStreakDays: 0,
  );
}

void main() {
  test('fromSnapshot carries the same strongest/weakest through unchanged', () {
    final snapshot = _snapshot(const {
      AttributeType.health: 100,
      AttributeType.strength: 300,
      AttributeType.knowledge: 10,
    });

    final distribution = AttributeDistribution.fromSnapshot(snapshot);

    expect(distribution.strongest, snapshot.strongestAttribute);
    expect(distribution.weakest, snapshot.weakestAttribute);
    expect(distribution.xpByAttribute, snapshot.attributeXp);
  });

  test('percentOf matches IdentitySnapshot.attributePercent exactly', () {
    final snapshot = _snapshot(const {
      AttributeType.health: 25,
      AttributeType.strength: 75,
    });
    final distribution = AttributeDistribution.fromSnapshot(snapshot);

    for (final type in AttributeType.values) {
      expect(distribution.percentOf(type), snapshot.attributePercent(type));
    }
  });

  test('percentOf is 0.0 for an empty distribution', () {
    final distribution = AttributeDistribution.fromSnapshot(
      _snapshot(const {}),
    );
    expect(distribution.percentOf(AttributeType.health), 0.0);
  });

  test('equal distributions compare equal', () {
    final a = AttributeDistribution.fromSnapshot(
      _snapshot(const {AttributeType.health: 50}),
    );
    final b = AttributeDistribution.fromSnapshot(
      _snapshot(const {AttributeType.health: 50}),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
