import '../entities/recommendation_profile.dart';

/// Local-only persistence for the user's recommendation profile. Returns
/// [RecommendationProfile.defaultProfile] when nothing has been saved yet —
/// callers never need to null-check.
abstract interface class RecommendationProfileRepository {
  Future<RecommendationProfile> get();

  Future<void> save(RecommendationProfile profile);

  /// Records that [suggestionId] has been turned into a quest, without
  /// otherwise touching the rest of the profile or marking it
  /// [RecommendationProfile.isPersonalized] — accepting a suggestion is not
  /// the same as explicitly customizing preferences via the editor (see
  /// `SaveRecommendationProfileUseCase`). A no-op if already recorded.
  Future<void> markSuggestionAccepted(String suggestionId);
}
