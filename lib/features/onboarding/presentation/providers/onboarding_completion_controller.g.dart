// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_completion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(OnboardingCompletionController)
final onboardingCompletionControllerProvider =
    OnboardingCompletionControllerProvider._();

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
final class OnboardingCompletionControllerProvider
    extends
        $AsyncNotifierProvider<OnboardingCompletionController, List<Quest>?> {
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
  OnboardingCompletionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingCompletionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingCompletionControllerHash();

  @$internal
  @override
  OnboardingCompletionController create() => OnboardingCompletionController();
}

String _$onboardingCompletionControllerHash() =>
    r'a818e0ede523a402d1ba1beaa3a968896401eb3d';

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

abstract class _$OnboardingCompletionController
    extends $AsyncNotifier<List<Quest>?> {
  FutureOr<List<Quest>?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Quest>?>, List<Quest>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Quest>?>, List<Quest>?>,
              AsyncValue<List<Quest>?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
