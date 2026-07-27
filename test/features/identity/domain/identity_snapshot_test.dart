import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/identity/domain/entities/identity_snapshot.dart';

IdentitySnapshot _snapshot({
  int currentLevel = 1,
  int lifetimeXp = 0,
  int xpIntoCurrentLevel = 0,
  int xpNeededForNextLevel = 100,
  Map<AttributeType, int> attributeXp = const {},
  int completedQuests = 0,
  int completedChains = 0,
  int unlockedAchievements = 0,
  int currentStreakDays = 0,
  DateTime? firstQuestDate,
  DateTime? latestActivityDate,
}) {
  return IdentitySnapshot(
    currentLevel: currentLevel,
    lifetimeXp: lifetimeXp,
    xpIntoCurrentLevel: xpIntoCurrentLevel,
    xpNeededForNextLevel: xpNeededForNextLevel,
    attributeXp: attributeXp,
    completedQuests: completedQuests,
    completedChains: completedChains,
    unlockedAchievements: unlockedAchievements,
    currentStreakDays: currentStreakDays,
    firstQuestDate: firstQuestDate,
    latestActivityDate: latestActivityDate,
  );
}

void main() {
  group('progressRatio', () {
    test('computes the fraction into the current level', () {
      final snapshot = _snapshot(
        xpIntoCurrentLevel: 25,
        xpNeededForNextLevel: 100,
      );
      expect(snapshot.progressRatio, 0.25);
    });

    test('clamps to 1.0 even if into-level XP exceeds the requirement', () {
      final snapshot = _snapshot(
        xpIntoCurrentLevel: 150,
        xpNeededForNextLevel: 100,
      );
      expect(snapshot.progressRatio, 1.0);
    });

    test('is 0.0 when xpNeededForNextLevel is zero or negative', () {
      final snapshot = _snapshot(
        xpIntoCurrentLevel: 10,
        xpNeededForNextLevel: 0,
      );
      expect(snapshot.progressRatio, 0.0);
    });
  });

  group('strongestAttribute / weakestAttribute', () {
    test('both are null for an empty attribute distribution', () {
      final snapshot = _snapshot(attributeXp: const {});
      expect(snapshot.strongestAttribute, isNull);
      expect(snapshot.weakestAttribute, isNull);
    });

    test('both are null when every attribute has zero XP', () {
      final snapshot = _snapshot(
        attributeXp: const {AttributeType.health: 0, AttributeType.strength: 0},
      );
      expect(snapshot.strongestAttribute, isNull);
      expect(snapshot.weakestAttribute, isNull);
    });

    test('picks the single highest and lowest attribute', () {
      // Every attribute is given an explicit value so the "weakest" pick
      // reflects knowledge's real minimum, not an implicit 0 from an
      // attribute this map happens to omit.
      final snapshot = _snapshot(
        attributeXp: const {
          AttributeType.health: 100,
          AttributeType.strength: 300,
          AttributeType.discipline: 50,
          AttributeType.knowledge: 10,
          AttributeType.career: 40,
          AttributeType.finance: 60,
          AttributeType.relationships: 70,
          AttributeType.mindfulness: 80,
        },
      );
      expect(snapshot.strongestAttribute, AttributeType.strength);
      expect(snapshot.weakestAttribute, AttributeType.knowledge);
    });

    test('breaks ties deterministically by enum declaration order', () {
      // health and strength tie at 50 — health comes first in
      // AttributeType.values, so it must win the "strongest" tie.
      final snapshot = _snapshot(
        attributeXp: const {
          AttributeType.health: 50,
          AttributeType.strength: 50,
        },
      );
      expect(snapshot.strongestAttribute, AttributeType.health);
    });
  });

  group('attributePercent', () {
    test('is 0.0 when no attribute has earned any XP', () {
      final snapshot = _snapshot(attributeXp: const {});
      expect(snapshot.attributePercent(AttributeType.health), 0.0);
    });

    test('is this attribute\'s share of the total', () {
      final snapshot = _snapshot(
        attributeXp: const {
          AttributeType.health: 25,
          AttributeType.strength: 75,
        },
      );
      expect(snapshot.attributePercent(AttributeType.health), 0.25);
      expect(snapshot.attributePercent(AttributeType.strength), 0.75);
      expect(snapshot.attributePercent(AttributeType.knowledge), 0.0);
    });
  });

  group('equality', () {
    test('two snapshots with identical fields are equal', () {
      final a = _snapshot(
        currentLevel: 3,
        lifetimeXp: 250,
        attributeXp: const {AttributeType.health: 250},
        firstQuestDate: DateTime.utc(2026, 1, 1),
      );
      final b = _snapshot(
        currentLevel: 3,
        lifetimeXp: 250,
        attributeXp: const {AttributeType.health: 250},
        firstQuestDate: DateTime.utc(2026, 1, 1),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a difference in any field breaks equality', () {
      final a = _snapshot(currentLevel: 3);
      final b = _snapshot(currentLevel: 4);
      expect(a, isNot(b));
    });

    test('a difference in attributeXp values breaks equality', () {
      final a = _snapshot(attributeXp: const {AttributeType.health: 10});
      final b = _snapshot(attributeXp: const {AttributeType.health: 20});
      expect(a, isNot(b));
    });
  });
}
