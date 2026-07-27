import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'settings_providers.dart';

part 'clear_data_controller.g.dart';

/// Drives "clear all local data" through [ClearLocalDataUseCase] and exposes
/// the outcome as an [AsyncValue] — the same idle/loading/success/error
/// shape every other controller in this app uses:
/// - idle: `AsyncData(false)`.
/// - clearing: `AsyncLoading()` — the guard below makes a second confirm-tap
///   while this is in flight a no-op, same reasoning as
///   `DeleteQuestController`.
/// - success: `AsyncData(true)` — the caller (`SettingsPage`) reacts to this
///   by triggering `AppRestartScope.restart`, which is what actually resets
///   every provider/controller; this controller's own job ends at "the boxes
///   are cleared and reopened".
/// - error: `AsyncError` — the UI stays on Settings and shows this, same as
///   a failed quest deletion never navigating away.
///
/// `keepAlive: true` for the same reason as every other controller here: an
/// autoDispose default would risk Riverpod tearing this down mid-`await`.
@Riverpod(keepAlive: true)
class ClearDataController extends _$ClearDataController {
  @override
  FutureOr<bool> build() => false;

  Future<void> clear() async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      await ref.read(clearLocalDataUseCaseProvider).execute();
      state = const AsyncValue.data(true);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() => state = const AsyncValue.data(false);
}
