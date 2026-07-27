// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_evaluation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Triggers chain evaluation after the two quest-completion paths this app
/// has (binary, via [completeQuestControllerProvider]; quantity/duration,
/// via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — mirrors
/// `AchievementEvaluationController` (Phase 10) exactly, including running
/// once at boot so an existing account retroactively advances any chain
/// whose stages it already happens to have completed.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndAdvanceChainsUseCase]; this controller only reacts to *when*
/// to call it. `keepAlive: true` for the same reason as every other
/// completion-adjacent controller in this app.

@ProviderFor(ChainEvaluationController)
final chainEvaluationControllerProvider = ChainEvaluationControllerProvider._();

/// Triggers chain evaluation after the two quest-completion paths this app
/// has (binary, via [completeQuestControllerProvider]; quantity/duration,
/// via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — mirrors
/// `AchievementEvaluationController` (Phase 10) exactly, including running
/// once at boot so an existing account retroactively advances any chain
/// whose stages it already happens to have completed.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndAdvanceChainsUseCase]; this controller only reacts to *when*
/// to call it. `keepAlive: true` for the same reason as every other
/// completion-adjacent controller in this app.
final class ChainEvaluationControllerProvider
    extends $NotifierProvider<ChainEvaluationController, ChainEvaluationState> {
  /// Triggers chain evaluation after the two quest-completion paths this app
  /// has (binary, via [completeQuestControllerProvider]; quantity/duration,
  /// via [questProgressControllerProvider]'s
  /// `UpdateQuestProgressResult.completionResult`) and once more at this
  /// controller's own creation — mirrors
  /// `AchievementEvaluationController` (Phase 10) exactly, including running
  /// once at boot so an existing account retroactively advances any chain
  /// whose stages it already happens to have completed.
  ///
  /// Holds no evaluation logic of its own — every decision comes from
  /// [EvaluateAndAdvanceChainsUseCase]; this controller only reacts to *when*
  /// to call it. `keepAlive: true` for the same reason as every other
  /// completion-adjacent controller in this app.
  ChainEvaluationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chainEvaluationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chainEvaluationControllerHash();

  @$internal
  @override
  ChainEvaluationController create() => ChainEvaluationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChainEvaluationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChainEvaluationState>(value),
    );
  }
}

String _$chainEvaluationControllerHash() =>
    r'b905afc0dfacc64b88823e0a14452c12e468f611';

/// Triggers chain evaluation after the two quest-completion paths this app
/// has (binary, via [completeQuestControllerProvider]; quantity/duration,
/// via [questProgressControllerProvider]'s
/// `UpdateQuestProgressResult.completionResult`) and once more at this
/// controller's own creation — mirrors
/// `AchievementEvaluationController` (Phase 10) exactly, including running
/// once at boot so an existing account retroactively advances any chain
/// whose stages it already happens to have completed.
///
/// Holds no evaluation logic of its own — every decision comes from
/// [EvaluateAndAdvanceChainsUseCase]; this controller only reacts to *when*
/// to call it. `keepAlive: true` for the same reason as every other
/// completion-adjacent controller in this app.

abstract class _$ChainEvaluationController
    extends $Notifier<ChainEvaluationState> {
  ChainEvaluationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChainEvaluationState, ChainEvaluationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChainEvaluationState, ChainEvaluationState>,
              ChainEvaluationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
