import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../application/models/create_quest_from_suggestion_outcome.dart';
import '../../domain/entities/quest_suggestion.dart';
import 'ranked_suggestions_provider.dart';
import 'recommendation_profile_controller.dart';
import 'suggestions_providers.dart';

part 'suggestion_creation_controller.g.dart';

/// Drives "Add Quest" for one suggestion through
/// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
/// each card on the Suggestions page has its own independent loading state
/// (adding one suggestion never disables the "Add" button on another).
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et
/// al.: an autoDispose default would let Riverpod tear this down mid-`await`
/// the moment the card unmounts (e.g. the ranked list re-sorts and the card
/// scrolls out of the viewport), silently losing an in-flight creation's
/// outcome — the exact "at most one quest" duplicate-prevention guard
/// (`state.isLoading` below) that this controller exists to provide.
@Riverpod(keepAlive: true)
class SuggestionCreationController extends _$SuggestionCreationController {
  @override
  FutureOr<CreateQuestFromSuggestionOutcome?> build(String suggestionId) =>
      null;

  /// [title]/[description] must be whatever the caller currently displays
  /// for this suggestion (see `suggestion_localization.dart`) — resolved
  /// here at the presentation/controller boundary, not inside the pure-Dart
  /// use case, so the persisted quest always matches what the user saw and
  /// tapped "Add" on, in whichever language that was (Phase 17.3.1 fix).
  Future<void> create(
    QuestSuggestion suggestion, {
    required String title,
    required String description,
  }) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(createQuestFromSuggestionUseCaseProvider);
    final result = await useCase.execute(
      suggestion,
      title: title,
      description: description,
    );

    switch (result) {
      case Ok(value: final outcome):
        state = AsyncValue.data(outcome);
        // Reflects the newly-accepted suggestion id (and, on the
        // already-exists path, nothing changes but is still safe to
        // refresh) so `rankedSuggestionsProvider` never re-offers it.
        ref.invalidate(recommendationProfileControllerProvider);
        ref.invalidate(rankedSuggestionsProvider);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle, ready for a future attempt (e.g. after showing an
  /// error and letting the user retry).
  void reset() => state = const AsyncValue.data(null);
}
