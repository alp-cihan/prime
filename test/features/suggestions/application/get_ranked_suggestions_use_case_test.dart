import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/suggestions/application/use_cases/get_ranked_suggestions_use_case.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

Quest _quest(String title) {
  return Quest(
    id: title,
    title: title,
    description: '',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 20},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void main() {
  test('ranks the real catalog against a profile', () {
    const useCase = GetRankedSuggestionsUseCase();

    final ranked = useCase.execute(
      profile: RecommendationProfile.defaultProfile.copyWith(
        lifeStage: LifeStage.student,
        goals: {GoalArea.study},
      ),
      existingQuests: const [],
    );

    expect(ranked, isNotEmpty);
    expect(ranked.length, questSuggestionCatalog.length);
  });

  test('excludes a suggestion whose title already exists as a quest', () {
    const useCase = GetRankedSuggestionsUseCase();
    final target = questSuggestionCatalog.first;

    final ranked = useCase.execute(
      profile: RecommendationProfile.defaultProfile,
      existingQuests: [_quest(target.title)],
    );

    expect(ranked.map((s) => s.id), isNot(contains(target.id)));
    expect(ranked.length, questSuggestionCatalog.length - 1);
  });

  test('title matching is case/whitespace-insensitive', () {
    const useCase = GetRankedSuggestionsUseCase();
    final target = questSuggestionCatalog.first;

    final ranked = useCase.execute(
      profile: RecommendationProfile.defaultProfile,
      existingQuests: [_quest('  ${target.title.toUpperCase()}  ')],
    );

    expect(ranked.map((s) => s.id), isNot(contains(target.id)));
  });

  test('applies the filterGoals filter', () {
    const useCase = GetRankedSuggestionsUseCase();

    final ranked = useCase.execute(
      profile: RecommendationProfile.defaultProfile,
      existingQuests: const [],
      filterGoals: {GoalArea.finance},
    );

    expect(ranked, isNotEmpty);
    for (final suggestion in ranked) {
      expect(suggestion.goals, contains(GoalArea.finance));
    }
  });
}
