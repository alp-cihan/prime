import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../domain/entities/quest_suggestion.dart';
import 'recommendation_profile_controller.dart';
import 'suggestion_filter_controller.dart';
import 'suggestions_providers.dart';

part 'ranked_suggestions_provider.g.dart';

/// The Suggestions page's ranked list — recomputes automatically whenever
/// any input changes: the live quest list (so a newly created/deleted quest
/// immediately affects duplicate exclusion, the same "existing streams"
/// mechanism the phase brief asks for), the recommendation profile
/// (editor saves, or a suggestion being marked accepted), or the session
/// goal filter.
@riverpod
Future<List<QuestSuggestion>> rankedSuggestions(Ref ref) async {
  final quests = await ref.watch(watchAllQuestsProvider.future);
  final profile = await ref.watch(
    recommendationProfileControllerProvider.future,
  );
  final filterGoals = ref.watch(suggestionFilterControllerProvider);
  final useCase = ref.watch(getRankedSuggestionsUseCaseProvider);

  return useCase.execute(
    profile: profile,
    existingQuests: quests,
    filterGoals: filterGoals,
  );
}
