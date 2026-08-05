import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/recommendation_profile.dart';
import '../../domain/repositories/recommendation_profile_repository.dart';

/// Persists a user-edited [RecommendationProfile], always marking it
/// [RecommendationProfile.isPersonalized] — reaching this use case only
/// happens via the preferences editor's explicit "Save" action, which is
/// exactly what that flag means.
class SaveRecommendationProfileUseCase {
  const SaveRecommendationProfileUseCase({
    required RecommendationProfileRepository repository,
  }) : _repository = repository;

  final RecommendationProfileRepository _repository;

  Future<Result<RecommendationProfile>> execute(
    RecommendationProfile profile,
  ) async {
    final personalized = profile.copyWith(isPersonalized: true);
    try {
      await _repository.save(personalized);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to save preferences: $e'));
    }
    return Ok(personalized);
  }
}
