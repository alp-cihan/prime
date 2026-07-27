// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clear_data_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(ClearDataController)
final clearDataControllerProvider = ClearDataControllerProvider._();

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
final class ClearDataControllerProvider
    extends $AsyncNotifierProvider<ClearDataController, bool> {
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
  ClearDataControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearDataControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearDataControllerHash();

  @$internal
  @override
  ClearDataController create() => ClearDataController();
}

String _$clearDataControllerHash() =>
    r'e8d1326efbed10296c69829b56f4e4d73b54e844';

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

abstract class _$ClearDataController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
