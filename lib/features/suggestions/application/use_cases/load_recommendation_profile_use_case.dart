import '../../domain/entities/recommendation_profile.dart';
import '../../domain/repositories/recommendation_profile_repository.dart';

class LoadRecommendationProfileUseCase {
  const LoadRecommendationProfileUseCase({
    required RecommendationProfileRepository repository,
  }) : _repository = repository;

  final RecommendationProfileRepository _repository;

  Future<RecommendationProfile> execute() => _repository.get();
}
