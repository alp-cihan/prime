// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_quest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(DeleteQuestController)
final deleteQuestControllerProvider = DeleteQuestControllerProvider._();

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
final class DeleteQuestControllerProvider
    extends $AsyncNotifierProvider<DeleteQuestController, bool> {
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
  DeleteQuestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteQuestControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteQuestControllerHash();

  @$internal
  @override
  DeleteQuestController create() => DeleteQuestController();
}

String _$deleteQuestControllerHash() =>
    r'cc16ffe2a437dd44b7febbb93c4e0f806da7d8da';

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

abstract class _$DeleteQuestController extends $AsyncNotifier<bool> {
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
