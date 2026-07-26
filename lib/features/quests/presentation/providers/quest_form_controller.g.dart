// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(QuestFormController)
final questFormControllerProvider = QuestFormControllerProvider._();

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
final class QuestFormControllerProvider
    extends $AsyncNotifierProvider<QuestFormController, Quest?> {
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
  QuestFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questFormControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questFormControllerHash();

  @$internal
  @override
  QuestFormController create() => QuestFormController();
}

String _$questFormControllerHash() =>
    r'df6e809d025f8dd3a6190790832176e59fe398f8';

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

abstract class _$QuestFormController extends $AsyncNotifier<Quest?> {
  FutureOr<Quest?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Quest?>, Quest?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Quest?>, Quest?>,
              AsyncValue<Quest?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
