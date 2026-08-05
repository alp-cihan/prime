import '../../domain/entities/recommendation_profile.dart';
import '../models/recommendation_profile_hive_model.dart';

/// Explicit domain <-> persistence mapping for [RecommendationProfile].
/// Enums are stored as their `.name` string, same convention as
/// `QuestMapper` — resilient to declaration-order changes and avoids
/// spending a `typeId` per enum.
class RecommendationProfileMapper {
  const RecommendationProfileMapper();

  RecommendationProfileHiveModel toModel(RecommendationProfile profile) {
    return RecommendationProfileHiveModel(
      lifeStage: profile.lifeStage.name,
      goals: [for (final goal in profile.goals) goal.name],
      availableTime: profile.availableTime.name,
      intensity: profile.intensity.name,
      isPersonalized: profile.isPersonalized,
      acceptedSuggestionIds: profile.acceptedSuggestionIds.toList(),
    );
  }

  RecommendationProfile toDomain(RecommendationProfileHiveModel model) {
    return RecommendationProfile(
      lifeStage: LifeStage.values.byName(model.lifeStage),
      goals: {for (final goal in model.goals) GoalArea.values.byName(goal)},
      availableTime: AvailableTime.values.byName(model.availableTime),
      intensity: PreferredIntensity.values.byName(model.intensity),
      isPersonalized: model.isPersonalized,
      acceptedSuggestionIds: model.acceptedSuggestionIds.toSet(),
    );
  }
}
