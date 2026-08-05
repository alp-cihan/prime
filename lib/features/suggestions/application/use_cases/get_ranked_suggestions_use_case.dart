import '../../../quests/domain/entities/quest.dart';
import '../../domain/catalog/quest_suggestion_catalog.dart';
import '../../domain/entities/quest_suggestion.dart';
import '../../domain/entities/recommendation_profile.dart';
import '../../domain/normalize_title.dart';
import '../../domain/services/suggestion_ranking_policy.dart';

/// Composes the pure [SuggestionRankingPolicy] with the code-defined
/// [questSuggestionCatalog] and the caller's current quests (normalized to
/// titles, for duplicate exclusion) — the one place that turns "what does
/// the user already have" into the policy's plain `Set<String>` input.
class GetRankedSuggestionsUseCase {
  const GetRankedSuggestionsUseCase({
    this.policy = const SuggestionRankingPolicy(),
    this.catalog = questSuggestionCatalog,
  });

  final SuggestionRankingPolicy policy;
  final List<QuestSuggestion> catalog;

  List<QuestSuggestion> execute({
    required RecommendationProfile profile,
    required List<Quest> existingQuests,
    Set<GoalArea> filterGoals = const <GoalArea>{},
  }) {
    final existingNormalizedTitles = {
      for (final quest in existingQuests) normalizeQuestTitle(quest.title),
    };
    return policy.rank(
      catalog: catalog,
      profile: profile,
      existingNormalizedTitles: existingNormalizedTitles,
      filterGoals: filterGoals,
    );
  }
}
