import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/persistence_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../../application/use_cases/create_quest_from_suggestion_use_case.dart';
import '../../application/use_cases/get_ranked_suggestions_use_case.dart';
import '../../application/use_cases/load_recommendation_profile_use_case.dart';
import '../../application/use_cases/save_recommendation_profile_use_case.dart';
import '../../data/repositories/hive_recommendation_profile_repository.dart';
import '../../domain/repositories/recommendation_profile_repository.dart';
import '../../domain/services/suggestion_ranking_policy.dart';

part 'suggestions_providers.g.dart';

/// Singletons for the app's lifetime — same reasoning as every other
/// repository/use-case provider in `quest_repository_providers.dart`: each
/// wraps an already-open Hive box or holds no mutable state of its own, so
/// nothing about it needs to be recreated mid-session.
@Riverpod(keepAlive: true)
RecommendationProfileRepository recommendationProfileRepository(Ref ref) {
  return HiveRecommendationProfileRepository(
    ref.watch(recommendationProfileHiveBoxProvider),
  );
}

@Riverpod(keepAlive: true)
SuggestionRankingPolicy suggestionRankingPolicy(Ref ref) =>
    const SuggestionRankingPolicy();

@Riverpod(keepAlive: true)
GetRankedSuggestionsUseCase getRankedSuggestionsUseCase(Ref ref) {
  return GetRankedSuggestionsUseCase(
    policy: ref.watch(suggestionRankingPolicyProvider),
  );
}

@Riverpod(keepAlive: true)
LoadRecommendationProfileUseCase loadRecommendationProfileUseCase(Ref ref) {
  return LoadRecommendationProfileUseCase(
    repository: ref.watch(recommendationProfileRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
SaveRecommendationProfileUseCase saveRecommendationProfileUseCase(Ref ref) {
  return SaveRecommendationProfileUseCase(
    repository: ref.watch(recommendationProfileRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
CreateQuestFromSuggestionUseCase createQuestFromSuggestionUseCase(Ref ref) {
  return CreateQuestFromSuggestionUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    createQuestUseCase: ref.watch(createQuestUseCaseProvider),
    recommendationProfileRepository: ref.watch(
      recommendationProfileRepositoryProvider,
    ),
  );
}
