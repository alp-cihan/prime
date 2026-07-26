// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_quest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives one quest completion through [CompleteQuestUseCase] and exposes
/// its outcome as an [AsyncValue]:
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - loading: `AsyncLoading()`, set synchronously before the use case runs.
/// - success: `AsyncData(CompleteQuestResult)`.
/// - error: `AsyncError(Failure, StackTrace)` — the [Failure] returned by
///   the use case's [Result], never a thrown exception, so a failed
///   completion never throws through the widget tree.
///
/// Holds no XP logic of its own — every number in the result comes from
/// [CompleteQuestUseCase]/[QuestXpCalculator], and this controller never
/// touches a repository or Hive box directly.
///
/// `keepAlive: true` is required, not just a convenience: with the default
/// autoDispose, a caller that invokes `ref.read(...notifier).complete(...)`
/// without also watching this provider elsewhere leaves it with zero
/// listeners the moment `complete` suspends at its first `await`. Riverpod
/// then disposes it mid-flight, and the later `state = ...` assignment
/// throws ("Cannot use the Ref ... after it has been disposed") instead of
/// ever recording the result — silently losing a completion outcome the
/// user is very likely to check again (e.g. after briefly navigating away
/// and back).

@ProviderFor(CompleteQuestController)
final completeQuestControllerProvider = CompleteQuestControllerProvider._();

/// Drives one quest completion through [CompleteQuestUseCase] and exposes
/// its outcome as an [AsyncValue]:
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - loading: `AsyncLoading()`, set synchronously before the use case runs.
/// - success: `AsyncData(CompleteQuestResult)`.
/// - error: `AsyncError(Failure, StackTrace)` — the [Failure] returned by
///   the use case's [Result], never a thrown exception, so a failed
///   completion never throws through the widget tree.
///
/// Holds no XP logic of its own — every number in the result comes from
/// [CompleteQuestUseCase]/[QuestXpCalculator], and this controller never
/// touches a repository or Hive box directly.
///
/// `keepAlive: true` is required, not just a convenience: with the default
/// autoDispose, a caller that invokes `ref.read(...notifier).complete(...)`
/// without also watching this provider elsewhere leaves it with zero
/// listeners the moment `complete` suspends at its first `await`. Riverpod
/// then disposes it mid-flight, and the later `state = ...` assignment
/// throws ("Cannot use the Ref ... after it has been disposed") instead of
/// ever recording the result — silently losing a completion outcome the
/// user is very likely to check again (e.g. after briefly navigating away
/// and back).
final class CompleteQuestControllerProvider
    extends
        $AsyncNotifierProvider<CompleteQuestController, CompleteQuestResult?> {
  /// Drives one quest completion through [CompleteQuestUseCase] and exposes
  /// its outcome as an [AsyncValue]:
  /// - idle: `AsyncData(null)` (the initial state, and after [reset]).
  /// - loading: `AsyncLoading()`, set synchronously before the use case runs.
  /// - success: `AsyncData(CompleteQuestResult)`.
  /// - error: `AsyncError(Failure, StackTrace)` — the [Failure] returned by
  ///   the use case's [Result], never a thrown exception, so a failed
  ///   completion never throws through the widget tree.
  ///
  /// Holds no XP logic of its own — every number in the result comes from
  /// [CompleteQuestUseCase]/[QuestXpCalculator], and this controller never
  /// touches a repository or Hive box directly.
  ///
  /// `keepAlive: true` is required, not just a convenience: with the default
  /// autoDispose, a caller that invokes `ref.read(...notifier).complete(...)`
  /// without also watching this provider elsewhere leaves it with zero
  /// listeners the moment `complete` suspends at its first `await`. Riverpod
  /// then disposes it mid-flight, and the later `state = ...` assignment
  /// throws ("Cannot use the Ref ... after it has been disposed") instead of
  /// ever recording the result — silently losing a completion outcome the
  /// user is very likely to check again (e.g. after briefly navigating away
  /// and back).
  CompleteQuestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeQuestControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeQuestControllerHash();

  @$internal
  @override
  CompleteQuestController create() => CompleteQuestController();
}

String _$completeQuestControllerHash() =>
    r'd49688ffd87210d406af87d7ebd3ba4354eba7a2';

/// Drives one quest completion through [CompleteQuestUseCase] and exposes
/// its outcome as an [AsyncValue]:
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - loading: `AsyncLoading()`, set synchronously before the use case runs.
/// - success: `AsyncData(CompleteQuestResult)`.
/// - error: `AsyncError(Failure, StackTrace)` — the [Failure] returned by
///   the use case's [Result], never a thrown exception, so a failed
///   completion never throws through the widget tree.
///
/// Holds no XP logic of its own — every number in the result comes from
/// [CompleteQuestUseCase]/[QuestXpCalculator], and this controller never
/// touches a repository or Hive box directly.
///
/// `keepAlive: true` is required, not just a convenience: with the default
/// autoDispose, a caller that invokes `ref.read(...notifier).complete(...)`
/// without also watching this provider elsewhere leaves it with zero
/// listeners the moment `complete` suspends at its first `await`. Riverpod
/// then disposes it mid-flight, and the later `state = ...` assignment
/// throws ("Cannot use the Ref ... after it has been disposed") instead of
/// ever recording the result — silently losing a completion outcome the
/// user is very likely to check again (e.g. after briefly navigating away
/// and back).

abstract class _$CompleteQuestController
    extends $AsyncNotifier<CompleteQuestResult?> {
  FutureOr<CompleteQuestResult?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<CompleteQuestResult?>, CompleteQuestResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CompleteQuestResult?>,
                CompleteQuestResult?
              >,
              AsyncValue<CompleteQuestResult?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
