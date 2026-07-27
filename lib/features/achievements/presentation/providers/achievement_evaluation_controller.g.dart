// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_evaluation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Triggers achievement evaluation after the two quest-completion paths this
/// app has (binary, via [completeQuestControllerProvider]; quantity/
/// duration, via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — the latter so an existing account
/// retroactively unlocks anything it already qualifies for the first time
/// it's evaluated (e.g. right after this feature ships), without needing to
/// complete a new quest first.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndUnlockAchievementsUseCase]; this controller only reacts to
/// *when* to call it and queues whatever it returns for the UI.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController`/
/// `LevelUpController`: an autoDispose default would let this be torn down
/// mid-evaluation the moment its last watcher unmounts.

@ProviderFor(AchievementEvaluationController)
final achievementEvaluationControllerProvider =
    AchievementEvaluationControllerProvider._();

/// Triggers achievement evaluation after the two quest-completion paths this
/// app has (binary, via [completeQuestControllerProvider]; quantity/
/// duration, via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — the latter so an existing account
/// retroactively unlocks anything it already qualifies for the first time
/// it's evaluated (e.g. right after this feature ships), without needing to
/// complete a new quest first.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndUnlockAchievementsUseCase]; this controller only reacts to
/// *when* to call it and queues whatever it returns for the UI.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController`/
/// `LevelUpController`: an autoDispose default would let this be torn down
/// mid-evaluation the moment its last watcher unmounts.
final class AchievementEvaluationControllerProvider
    extends
        $NotifierProvider<
          AchievementEvaluationController,
          AchievementEvaluationState
        > {
  /// Triggers achievement evaluation after the two quest-completion paths this
  /// app has (binary, via [completeQuestControllerProvider]; quantity/
  /// duration, via [questProgressControllerProvider]'s
  /// `UpdateQuestProgressResult.completionResult`) and once more at this
  /// controller's own creation — the latter so an existing account
  /// retroactively unlocks anything it already qualifies for the first time
  /// it's evaluated (e.g. right after this feature ships), without needing to
  /// complete a new quest first.
  ///
  /// Holds no evaluation logic of its own — every decision comes from
  /// [EvaluateAndUnlockAchievementsUseCase]; this controller only reacts to
  /// *when* to call it and queues whatever it returns for the UI.
  ///
  /// `keepAlive: true` for the same reason as `CompleteQuestController`/
  /// `LevelUpController`: an autoDispose default would let this be torn down
  /// mid-evaluation the moment its last watcher unmounts.
  AchievementEvaluationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'achievementEvaluationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$achievementEvaluationControllerHash();

  @$internal
  @override
  AchievementEvaluationController create() => AchievementEvaluationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AchievementEvaluationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AchievementEvaluationState>(value),
    );
  }
}

String _$achievementEvaluationControllerHash() =>
    r'753f691ddd81dd137089bd7e9c992564371bebc6';

/// Triggers achievement evaluation after the two quest-completion paths this
/// app has (binary, via [completeQuestControllerProvider]; quantity/
/// duration, via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — the latter so an existing account
/// retroactively unlocks anything it already qualifies for the first time
/// it's evaluated (e.g. right after this feature ships), without needing to
/// complete a new quest first.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndUnlockAchievementsUseCase]; this controller only reacts to
/// *when* to call it and queues whatever it returns for the UI.
///
/// `keepAlive: true` for the same reason as `CompleteQuestController`/
/// `LevelUpController`: an autoDispose default would let this be torn down
/// mid-evaluation the moment its last watcher unmounts.

abstract class _$AchievementEvaluationController
    extends $Notifier<AchievementEvaluationState> {
  AchievementEvaluationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AchievementEvaluationState, AchievementEvaluationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AchievementEvaluationState,
                AchievementEvaluationState
              >,
              AchievementEvaluationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
