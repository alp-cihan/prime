import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/suggestions/data/models/recommendation_profile_hive_model.dart';
import 'package:prime/features/suggestions/data/repositories/hive_recommendation_profile_repository.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

import '../../../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test(
    'defaults to RecommendationProfile.defaultProfile for a fresh install',
    () async {
      final box = await Hive.openBox<RecommendationProfileHiveModel>(
        HiveBoxNames.recommendationProfile,
      );
      final repository = HiveRecommendationProfileRepository(box);

      expect(await repository.get(), RecommendationProfile.defaultProfile);
    },
  );

  test('save persists the profile', () async {
    final box = await Hive.openBox<RecommendationProfileHiveModel>(
      HiveBoxNames.recommendationProfile,
    );
    final repository = HiveRecommendationProfileRepository(box);
    const profile = RecommendationProfile(
      lifeStage: LifeStage.student,
      goals: {GoalArea.study, GoalArea.reading},
      availableTime: AvailableTime.under15,
      intensity: PreferredIntensity.gentle,
      isPersonalized: true,
      acceptedSuggestionIds: {},
    );

    await repository.save(profile);

    expect(await repository.get(), profile);
  });

  test('persists across a restart', () async {
    final box = await Hive.openBox<RecommendationProfileHiveModel>(
      HiveBoxNames.recommendationProfile,
    );
    const profile = RecommendationProfile(
      lifeStage: LifeStage.retired,
      goals: {GoalArea.mindfulness},
      availableTime: AvailableTime.over60,
      intensity: PreferredIntensity.balanced,
      isPersonalized: true,
      acceptedSuggestionIds: {'walk_20'},
    );
    await HiveRecommendationProfileRepository(box).save(profile);

    await support.reopen();
    final reopened = await Hive.openBox<RecommendationProfileHiveModel>(
      HiveBoxNames.recommendationProfile,
    );

    expect(await HiveRecommendationProfileRepository(reopened).get(), profile);
  });

  test(
    'markSuggestionAccepted adds the id without touching other fields',
    () async {
      final box = await Hive.openBox<RecommendationProfileHiveModel>(
        HiveBoxNames.recommendationProfile,
      );
      final repository = HiveRecommendationProfileRepository(box);
      const profile = RecommendationProfile(
        lifeStage: LifeStage.homemaker,
        goals: {GoalArea.organization},
        availableTime: AvailableTime.min30to60,
        intensity: PreferredIntensity.balanced,
        isPersonalized: true,
        acceptedSuggestionIds: {},
      );
      await repository.save(profile);

      await repository.markSuggestionAccepted('walk_20');

      final result = await repository.get();
      expect(result.acceptedSuggestionIds, {'walk_20'});
      expect(result.isPersonalized, isTrue); // untouched, still true
      expect(result.lifeStage, LifeStage.homemaker); // untouched
    },
  );

  test('markSuggestionAccepted is a no-op if already recorded', () async {
    final box = await Hive.openBox<RecommendationProfileHiveModel>(
      HiveBoxNames.recommendationProfile,
    );
    final repository = HiveRecommendationProfileRepository(box);
    await repository.markSuggestionAccepted('walk_20');
    await repository.markSuggestionAccepted('walk_20');

    expect((await repository.get()).acceptedSuggestionIds, {'walk_20'});
  });
}
