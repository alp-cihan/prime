import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement.dart';
import 'package:prime/features/achievements/domain/entities/achievement_trigger.dart';
import 'package:prime/features/achievements/domain/services/achievement_criteria_snapshot.dart';
import 'package:prime/features/achievements/domain/services/achievement_evaluation_policy.dart';

Achievement _achievement({
  AchievementTrigger trigger = AchievementTrigger.totalQuestCompletions,
  int threshold = 1,
  AttributeType? attributeType,
}) {
  return Achievement(
    id: 'test',
    title: 'Test',
    description: 'desc',
    iconKey: 'star',
    trigger: trigger,
    threshold: threshold,
    attributeType: attributeType,
    sortOrder: 0,
  );
}

AchievementCriteriaSnapshot _snapshot({
  int totalQuestCompletions = 0,
  int lifetimeXp = 0,
  int playerLevel = 1,
  Map<AttributeType, int> xpByAttribute = const {},
  int hardOrAboveCompletionCount = 0,
  int longestConsecutiveCompletionDayStreak = 0,
}) {
  return AchievementCriteriaSnapshot(
    totalQuestCompletions: totalQuestCompletions,
    lifetimeXp: lifetimeXp,
    playerLevel: playerLevel,
    xpByAttribute: xpByAttribute,
    hardOrAboveCompletionCount: hardOrAboveCompletionCount,
    longestConsecutiveCompletionDayStreak:
        longestConsecutiveCompletionDayStreak,
  );
}

void main() {
  const policy = AchievementEvaluationPolicy();

  group('totalQuestCompletions', () {
    test('below threshold is not satisfied', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.totalQuestCompletions,
        threshold: 5,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(totalQuestCompletions: 4)),
        isFalse,
      );
    });

    test('exactly at threshold is satisfied (boundary)', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.totalQuestCompletions,
        threshold: 5,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(totalQuestCompletions: 5)),
        isTrue,
      );
    });

    test('above threshold is satisfied', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.totalQuestCompletions,
        threshold: 5,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(totalQuestCompletions: 6)),
        isTrue,
      );
    });
  });

  group('lifetimeXpReached', () {
    test('boundary at exactly the threshold', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.lifetimeXpReached,
        threshold: 1000,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(lifetimeXp: 999)),
        isFalse,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(lifetimeXp: 1000)),
        isTrue,
      );
    });
  });

  group('playerLevelReached', () {
    test('boundary at exactly the threshold', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.playerLevelReached,
        threshold: 5,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(playerLevel: 4)),
        isFalse,
      );
      expect(
        policy.isSatisfied(achievement, _snapshot(playerLevel: 5)),
        isTrue,
      );
    });
  });

  group('attributeXpReached', () {
    test('a pinned attribute checks only that attribute', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.attributeXpReached,
        threshold: 500,
        attributeType: AttributeType.health,
      );
      final snapshot = _snapshot(
        xpByAttribute: {AttributeType.health: 499, AttributeType.strength: 900},
      );
      expect(policy.isSatisfied(achievement, snapshot), isFalse);
    });

    test('a pinned attribute is satisfied at its own boundary', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.attributeXpReached,
        threshold: 500,
        attributeType: AttributeType.health,
      );
      final snapshot = _snapshot(xpByAttribute: {AttributeType.health: 500});
      expect(policy.isSatisfied(achievement, snapshot), isTrue);
    });

    test(
      'no pinned attribute checks the single highest attribute, not the sum',
      () {
        final achievement = _achievement(
          trigger: AchievementTrigger.attributeXpReached,
          threshold: 500,
        );
        // Eight attributes summing well past 500, but no single one reaches it.
        final snapshot = _snapshot(
          xpByAttribute: {for (final type in AttributeType.values) type: 100},
        );
        expect(policy.isSatisfied(achievement, snapshot), isFalse);
      },
    );

    test(
      'no pinned attribute is satisfied once any one attribute reaches it',
      () {
        final achievement = _achievement(
          trigger: AchievementTrigger.attributeXpReached,
          threshold: 500,
        );
        final snapshot = _snapshot(
          xpByAttribute: {
            AttributeType.health: 500,
            AttributeType.strength: 10,
          },
        );
        expect(policy.isSatisfied(achievement, snapshot), isTrue);
      },
    );

    test('empty xpByAttribute never satisfies', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.attributeXpReached,
        threshold: 1,
      );
      expect(policy.isSatisfied(achievement, _snapshot()), isFalse);
    });
  });

  group('hardOrAboveQuestCompleted', () {
    test('boundary at exactly the threshold', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.hardOrAboveQuestCompleted,
        threshold: 1,
      );
      expect(
        policy.isSatisfied(
          achievement,
          _snapshot(hardOrAboveCompletionCount: 0),
        ),
        isFalse,
      );
      expect(
        policy.isSatisfied(
          achievement,
          _snapshot(hardOrAboveCompletionCount: 1),
        ),
        isTrue,
      );
    });
  });

  group('consecutiveDaysCompleted', () {
    test('boundary at exactly the threshold', () {
      final achievement = _achievement(
        trigger: AchievementTrigger.consecutiveDaysCompleted,
        threshold: 3,
      );
      expect(
        policy.isSatisfied(
          achievement,
          _snapshot(longestConsecutiveCompletionDayStreak: 2),
        ),
        isFalse,
      );
      expect(
        policy.isSatisfied(
          achievement,
          _snapshot(longestConsecutiveCompletionDayStreak: 3),
        ),
        isTrue,
      );
    });
  });

  group('progressRatio', () {
    test('clamps to 1.0 past the threshold', () {
      final achievement = _achievement(threshold: 5);
      expect(
        policy.progressRatio(achievement, _snapshot(totalQuestCompletions: 50)),
        1.0,
      );
    });

    test('is a simple current/threshold ratio below it', () {
      final achievement = _achievement(threshold: 4);
      expect(
        policy.progressRatio(achievement, _snapshot(totalQuestCompletions: 1)),
        0.25,
      );
    });

    test('is 0.0 with no progress at all', () {
      final achievement = _achievement(threshold: 4);
      expect(policy.progressRatio(achievement, _snapshot()), 0.0);
    });
  });
}
