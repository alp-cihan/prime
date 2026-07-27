import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../domain/catalog/starter_quest_template.dart';
import 'onboarding_providers.dart';

part 'onboarding_completion_controller.g.dart';

/// Drives "finish onboarding" (with or without selected starter templates)
/// through [CreateStarterQuestsUseCase] and exposes the outcome as an
/// [AsyncValue] — the same idle/loading/success/error shape every other
/// controller in this app uses:
/// - idle: `AsyncData(null)`.
/// - submitting: `AsyncLoading()` — the guard below turns a double-tap on
///   "Get Started" into a no-op, same reasoning as `QuestFormController`.
/// - success: `AsyncData(List<Quest>)` — the starter quests actually created
///   (empty if none were selected, or all selected titles already existed).
/// - error: `AsyncError`.
///
/// Onboarding is marked completed only on success, and only after the
/// starter quests (if any) are safely created — a failure here leaves
/// onboarding showing rather than silently losing the user's template
/// selections.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et al.:
/// an autoDispose default would let Riverpod tear this down mid-`await` the
/// moment the onboarding page unmounts (e.g. the very navigation this
/// controller's own success triggers).
@Riverpod(keepAlive: true)
class OnboardingCompletionController extends _$OnboardingCompletionController {
  @override
  FutureOr<List<Quest>?> build() => null;

  Future<void> finish(List<StarterQuestTemplate> selectedTemplates) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(createStarterQuestsUseCaseProvider);
    final result = await useCase.execute(selectedTemplates);

    switch (result) {
      case Ok(value: final quests):
        ref.read(onboardingRepositoryProvider).markCompleted();
        state = AsyncValue.data(quests);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle — called after a successful finish has been acted on
  /// (navigated away), so a later onboarding session never shows a stale
  /// success/error from a previous one.
  void reset() => state = const AsyncValue.data(null);
}
