import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../application/models/delete_quest_command.dart';
import 'quest_query_providers.dart';
import 'quest_repository_providers.dart';

part 'delete_quest_controller.g.dart';

/// Drives quest deletion through [DeleteQuestUseCase] and exposes the
/// outcome as an [AsyncValue<bool>]:
/// - idle: `AsyncData(false)` (the initial state, and after [reset]).
/// - deleting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below makes a second confirm-tap while this is
///   showing a no-op, so a duplicate deletion can never happen.
/// - success: `AsyncData(true)`.
/// - error: `AsyncError(Failure, StackTrace)` — the UI stays on the detail
///   screen and shows this, per Phase 7's requirement that a delete failure
///   never navigates away.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController`/
/// `QuestFormController`.
@Riverpod(keepAlive: true)
class DeleteQuestController extends _$DeleteQuestController {
  @override
  FutureOr<bool> build() => false;

  Future<void> delete(String questId) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(deleteQuestUseCaseProvider);
    final result = await useCase.execute(DeleteQuestCommand(questId: questId));

    switch (result) {
      case Ok(value: final success):
        state = AsyncValue.data(success);
        // watchAllQuestsProvider refreshes the list/dashboard on its own;
        // only the non-stream `questByIdProvider(questId)` family instance
        // needs an explicit invalidation, in case anything is still
        // watching it during the navigation-away transition.
        ref.invalidate(questByIdProvider(questId));
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle, ready for a future deletion.
  void reset() {
    state = const AsyncValue.data(false);
  }
}
