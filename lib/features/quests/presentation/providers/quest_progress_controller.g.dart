// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_progress_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives quantity/duration progress mutations through
/// [UpdateQuestProgressUseCase] and exposes the outcome as an
/// [AsyncValue] — the same idle/loading/success/error shape as every other
/// controller in this feature (`CompleteQuestController`,
/// `QuestFormController`, `DeleteQuestController`):
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - submitting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below turns an overlapping call into a no-op, so a
///   rapid double-tap on `+`/`-` can never submit two mutations at once.
/// - success: `AsyncData(UpdateQuestProgressResult)`.
/// - error: `AsyncError(Failure, StackTrace)`.
///
/// Binary quests are deliberately **not** routed through this controller —
/// they keep using the existing, already-tested
/// `CompleteQuestController`/`CompleteQuestButton` pair directly. See
/// `quest_detail_page.dart` for where that split is made.
///
/// `keepAlive: true` for the same reason as the other controllers: an
/// autoDispose default would let this get torn down mid-`await` the moment
/// its last watcher unmounts, silently losing the outcome of a mutation the
/// user is very likely to check (e.g. after a quick navigation).

@ProviderFor(QuestProgressController)
final questProgressControllerProvider = QuestProgressControllerProvider._();

/// Drives quantity/duration progress mutations through
/// [UpdateQuestProgressUseCase] and exposes the outcome as an
/// [AsyncValue] — the same idle/loading/success/error shape as every other
/// controller in this feature (`CompleteQuestController`,
/// `QuestFormController`, `DeleteQuestController`):
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - submitting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below turns an overlapping call into a no-op, so a
///   rapid double-tap on `+`/`-` can never submit two mutations at once.
/// - success: `AsyncData(UpdateQuestProgressResult)`.
/// - error: `AsyncError(Failure, StackTrace)`.
///
/// Binary quests are deliberately **not** routed through this controller —
/// they keep using the existing, already-tested
/// `CompleteQuestController`/`CompleteQuestButton` pair directly. See
/// `quest_detail_page.dart` for where that split is made.
///
/// `keepAlive: true` for the same reason as the other controllers: an
/// autoDispose default would let this get torn down mid-`await` the moment
/// its last watcher unmounts, silently losing the outcome of a mutation the
/// user is very likely to check (e.g. after a quick navigation).
final class QuestProgressControllerProvider
    extends
        $AsyncNotifierProvider<
          QuestProgressController,
          UpdateQuestProgressResult?
        > {
  /// Drives quantity/duration progress mutations through
  /// [UpdateQuestProgressUseCase] and exposes the outcome as an
  /// [AsyncValue] — the same idle/loading/success/error shape as every other
  /// controller in this feature (`CompleteQuestController`,
  /// `QuestFormController`, `DeleteQuestController`):
  /// - idle: `AsyncData(null)` (the initial state, and after [reset]).
  /// - submitting: `AsyncLoading()`, set synchronously before the use case
  ///   runs — the guard below turns an overlapping call into a no-op, so a
  ///   rapid double-tap on `+`/`-` can never submit two mutations at once.
  /// - success: `AsyncData(UpdateQuestProgressResult)`.
  /// - error: `AsyncError(Failure, StackTrace)`.
  ///
  /// Binary quests are deliberately **not** routed through this controller —
  /// they keep using the existing, already-tested
  /// `CompleteQuestController`/`CompleteQuestButton` pair directly. See
  /// `quest_detail_page.dart` for where that split is made.
  ///
  /// `keepAlive: true` for the same reason as the other controllers: an
  /// autoDispose default would let this get torn down mid-`await` the moment
  /// its last watcher unmounts, silently losing the outcome of a mutation the
  /// user is very likely to check (e.g. after a quick navigation).
  QuestProgressControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questProgressControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questProgressControllerHash();

  @$internal
  @override
  QuestProgressController create() => QuestProgressController();
}

String _$questProgressControllerHash() =>
    r'9ae6aada0a78970356a7339e1db8fd76d15439c9';

/// Drives quantity/duration progress mutations through
/// [UpdateQuestProgressUseCase] and exposes the outcome as an
/// [AsyncValue] — the same idle/loading/success/error shape as every other
/// controller in this feature (`CompleteQuestController`,
/// `QuestFormController`, `DeleteQuestController`):
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - submitting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below turns an overlapping call into a no-op, so a
///   rapid double-tap on `+`/`-` can never submit two mutations at once.
/// - success: `AsyncData(UpdateQuestProgressResult)`.
/// - error: `AsyncError(Failure, StackTrace)`.
///
/// Binary quests are deliberately **not** routed through this controller —
/// they keep using the existing, already-tested
/// `CompleteQuestController`/`CompleteQuestButton` pair directly. See
/// `quest_detail_page.dart` for where that split is made.
///
/// `keepAlive: true` for the same reason as the other controllers: an
/// autoDispose default would let this get torn down mid-`await` the moment
/// its last watcher unmounts, silently losing the outcome of a mutation the
/// user is very likely to check (e.g. after a quick navigation).

abstract class _$QuestProgressController
    extends $AsyncNotifier<UpdateQuestProgressResult?> {
  FutureOr<UpdateQuestProgressResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<UpdateQuestProgressResult?>,
              UpdateQuestProgressResult?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<UpdateQuestProgressResult?>,
                UpdateQuestProgressResult?
              >,
              AsyncValue<UpdateQuestProgressResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
