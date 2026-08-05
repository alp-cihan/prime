import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/suggestions/data/mappers/recommendation_profile_mapper.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';

void main() {
  const mapper = RecommendationProfileMapper();

  test('round-trips a fully populated profile', () {
    const profile = RecommendationProfile(
      lifeStage: LifeStage.entrepreneur,
      goals: {GoalArea.finance, GoalArea.career, GoalArea.organization},
      availableTime: AvailableTime.min15to30,
      intensity: PreferredIntensity.challenging,
      isPersonalized: true,
      acceptedSuggestionIds: {'s1', 's2'},
    );

    final roundTripped = mapper.toDomain(mapper.toModel(profile));

    expect(roundTripped, profile);
  });

  test('round-trips the default profile (empty goals/accepted ids)', () {
    const profile = RecommendationProfile.defaultProfile;

    final roundTripped = mapper.toDomain(mapper.toModel(profile));

    expect(roundTripped, profile);
    expect(roundTripped.goals, isEmpty);
    expect(roundTripped.acceptedSuggestionIds, isEmpty);
  });
}
