import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/services/quest_input_validator.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

void main() {
  const validator = QuestInputValidator();

  test('has at least 60 entries', () {
    expect(questSuggestionCatalog.length, greaterThanOrEqualTo(60));
  });

  test('every id is unique', () {
    final ids = questSuggestionCatalog.map((s) => s.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every title is unique', () {
    final titles = questSuggestionCatalog.map((s) => s.title).toList();
    expect(titles.toSet().length, titles.length);
  });

  test('every entry passes QuestInputValidator', () {
    for (final suggestion in questSuggestionCatalog) {
      final failure = validator.validate(
        title: suggestion.title,
        description: suggestion.description,
        attributeXpWeights: suggestion.attributeXpWeights,
        progressType: suggestion.progressType,
        targetProgress: suggestion.targetProgress,
      );
      expect(
        failure,
        isNull,
        reason: '${suggestion.id} failed validation: ${failure?.message}',
      );
    }
  });

  test('binary suggestions always target exactly 1', () {
    for (final suggestion in questSuggestionCatalog) {
      if (suggestion.progressType == ProgressType.binary) {
        expect(
          suggestion.targetProgress,
          1,
          reason:
              '${suggestion.id} is binary but targets '
              '${suggestion.targetProgress}',
        );
      }
    }
  });

  test('quantity/duration suggestions always target a positive amount', () {
    for (final suggestion in questSuggestionCatalog) {
      if (suggestion.progressType != ProgressType.binary) {
        expect(
          suggestion.targetProgress,
          greaterThan(0),
          reason: '${suggestion.id} targets ${suggestion.targetProgress}',
        );
      }
    }
  });

  test('every attribute weight is non-negative with at least one positive', () {
    for (final suggestion in questSuggestionCatalog) {
      expect(suggestion.attributeXpWeights, isNotEmpty, reason: suggestion.id);
      expect(
        suggestion.attributeXpWeights.values.every((v) => v >= 0),
        isTrue,
        reason: suggestion.id,
      );
      expect(
        suggestion.attributeXpWeights.values.any((v) => v > 0),
        isTrue,
        reason: suggestion.id,
      );
    }
  });

  test('every entry has a positive estimated duration and sort priority', () {
    for (final suggestion in questSuggestionCatalog) {
      expect(
        suggestion.estimatedMinutes,
        greaterThan(0),
        reason: suggestion.id,
      );
      expect(suggestion.sortPriority, greaterThan(0), reason: suggestion.id);
      expect(suggestion.visualKey, isNotEmpty, reason: suggestion.id);
    }
  });

  test('every entry covers every declared goal area at least once', () {
    final coveredGoals = <GoalArea>{
      for (final suggestion in questSuggestionCatalog) ...suggestion.goals,
    };
    for (final goal in GoalArea.values) {
      expect(coveredGoals, contains(goal), reason: 'no suggestion tags $goal');
    }
  });

  test('every life stage has at least one dedicated suggestion', () {
    final coveredStages = <LifeStage>{
      for (final suggestion in questSuggestionCatalog) ...suggestion.lifeStages,
    };
    for (final stage in LifeStage.values) {
      if (stage == LifeStage.other) continue; // "other" has no dedicated set
      expect(
        coveredStages,
        contains(stage),
        reason: 'no suggestion is written for $stage',
      );
    }
  });

  test('primaryAttribute picks the highest-weighted attribute', () {
    final multiAttribute = questSuggestionCatalog.firstWhere(
      (s) => s.attributeXpWeights.length > 1,
    );
    final expected = multiAttribute.attributeXpWeights.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    expect(multiAttribute.primaryAttribute, expected.key);
  });
}
