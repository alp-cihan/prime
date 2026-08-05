import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/suggestions/application/use_cases/load_recommendation_profile_use_case.dart';
import 'package:prime/features/suggestions/application/use_cases/save_recommendation_profile_use_case.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

import '../../../support/fake_repositories.dart';

void main() {
  test('load returns the default profile before anything is saved', () async {
    final repository = FakeRecommendationProfileRepository();
    final useCase = LoadRecommendationProfileUseCase(repository: repository);

    expect(await useCase.execute(), RecommendationProfile.defaultProfile);
  });

  test('save always marks the profile isPersonalized, even if the caller '
      "didn't set it", () async {
    final repository = FakeRecommendationProfileRepository();
    final useCase = SaveRecommendationProfileUseCase(repository: repository);
    const edited = RecommendationProfile(
      lifeStage: LifeStage.workingProfessional,
      goals: {GoalArea.career},
      availableTime: AvailableTime.min15to30,
      intensity: PreferredIntensity.balanced,
      isPersonalized: false,
      acceptedSuggestionIds: {},
    );

    final result = await useCase.execute(edited);

    expect(result, isA<Ok<RecommendationProfile>>());
    final saved = (result as Ok<RecommendationProfile>).value;
    expect(saved.isPersonalized, isTrue);
    expect(saved.lifeStage, LifeStage.workingProfessional);
    expect(await repository.get(), saved);
  });

  test('load reflects what was previously saved', () async {
    final repository = FakeRecommendationProfileRepository();
    final loadUseCase = LoadRecommendationProfileUseCase(
      repository: repository,
    );
    final saveUseCase = SaveRecommendationProfileUseCase(
      repository: repository,
    );
    const edited = RecommendationProfile(
      lifeStage: LifeStage.retired,
      goals: {GoalArea.reading, GoalArea.mindfulness},
      availableTime: AvailableTime.over60,
      intensity: PreferredIntensity.gentle,
      isPersonalized: false,
      acceptedSuggestionIds: {},
    );

    await saveUseCase.execute(edited);

    final loaded = await loadUseCase.execute();
    expect(loaded.lifeStage, LifeStage.retired);
    expect(loaded.goals, {GoalArea.reading, GoalArea.mindfulness});
    expect(loaded.isPersonalized, isTrue);
  });
}
