import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../application/models/create_quest_command.dart';
import '../../application/models/update_quest_command.dart';
import '../../domain/entities/quest.dart';
import 'quest_query_providers.dart';
import 'quest_repository_providers.dart';

part 'quest_form_controller.g.dart';

/// Drives quest creation and editing through [CreateQuestUseCase]/
/// [UpdateQuestUseCase] and exposes the outcome as an [AsyncValue] — the
/// same idle/loading/success/error shape as `CompleteQuestController`:
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - submitting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below turns a second tap while this is showing into a
///   no-op, so a duplicate submission can never create/save twice.
/// - success: `AsyncData(Quest)` — the created or updated quest.
/// - error: `AsyncError(Failure, StackTrace)`.
///
/// Holds no validation or persistence logic of its own — every rule lives in
/// [QuestInputValidator] via the use cases, and this controller never
/// touches a repository or Hive box directly.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController`: an
/// autoDispose default would let Riverpod tear this down mid-`await` the
/// moment its last watcher unmounts (e.g. a quick navigation), silently
/// losing the outcome of a submission the user is very likely to check.
@Riverpod(keepAlive: true)
class QuestFormController extends _$QuestFormController {
  @override
  FutureOr<Quest?> build() => null;

  Future<void> create(CreateQuestCommand command) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(createQuestUseCaseProvider);
    final result = await useCase.execute(command);

    switch (result) {
      case Ok(value: final quest):
        state = AsyncValue.data(quest);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Named `updateQuest` (not `update`) — `AsyncNotifier` already declares
  /// an inherited `update(cb, {onError})` for optimistic state updates, and
  /// reusing that name here would override it with an incompatible
  /// signature.
  Future<void> updateQuest(UpdateQuestCommand command) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(updateQuestUseCaseProvider);
    final result = await useCase.execute(command);

    switch (result) {
      case Ok(value: final quest):
        state = AsyncValue.data(quest);
        // watchAllQuestsProvider refreshes the list/dashboard on its own
        // (the Hive box's own `watch()` stream) — only the non-stream
        // `questByIdProvider(questId)` family instance needs an explicit
        // invalidation so an already-open detail page shows the edit.
        ref.invalidate(questByIdProvider(command.questId));
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle, ready for a future create/edit.
  void reset() {
    state = const AsyncValue.data(null);
  }
}
