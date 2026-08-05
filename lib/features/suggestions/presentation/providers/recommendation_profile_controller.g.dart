// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single source of truth for the current [RecommendationProfile] —
/// loads it once on first watch, and every save flows back through this
/// controller so every other provider watching it (ranked suggestions, the
/// preferences editor) sees the update immediately.
///
/// `keepAlive: true` for the same reason as every other mutation controller
/// in this app (`QuestFormController` et al.): an autoDispose default would
/// let Riverpod tear this down mid-`await` the moment its last watcher
/// unmounts, silently losing a save the user is very likely to check again.

@ProviderFor(RecommendationProfileController)
final recommendationProfileControllerProvider =
    RecommendationProfileControllerProvider._();

/// The single source of truth for the current [RecommendationProfile] —
/// loads it once on first watch, and every save flows back through this
/// controller so every other provider watching it (ranked suggestions, the
/// preferences editor) sees the update immediately.
///
/// `keepAlive: true` for the same reason as every other mutation controller
/// in this app (`QuestFormController` et al.): an autoDispose default would
/// let Riverpod tear this down mid-`await` the moment its last watcher
/// unmounts, silently losing a save the user is very likely to check again.
final class RecommendationProfileControllerProvider
    extends
        $AsyncNotifierProvider<
          RecommendationProfileController,
          RecommendationProfile
        > {
  /// The single source of truth for the current [RecommendationProfile] —
  /// loads it once on first watch, and every save flows back through this
  /// controller so every other provider watching it (ranked suggestions, the
  /// preferences editor) sees the update immediately.
  ///
  /// `keepAlive: true` for the same reason as every other mutation controller
  /// in this app (`QuestFormController` et al.): an autoDispose default would
  /// let Riverpod tear this down mid-`await` the moment its last watcher
  /// unmounts, silently losing a save the user is very likely to check again.
  RecommendationProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationProfileControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationProfileControllerHash();

  @$internal
  @override
  RecommendationProfileController create() => RecommendationProfileController();
}

String _$recommendationProfileControllerHash() =>
    r'96e54f20bfaea74bf724bb214779439c829aaee6';

/// The single source of truth for the current [RecommendationProfile] —
/// loads it once on first watch, and every save flows back through this
/// controller so every other provider watching it (ranked suggestions, the
/// preferences editor) sees the update immediately.
///
/// `keepAlive: true` for the same reason as every other mutation controller
/// in this app (`QuestFormController` et al.): an autoDispose default would
/// let Riverpod tear this down mid-`await` the moment its last watcher
/// unmounts, silently losing a save the user is very likely to check again.

abstract class _$RecommendationProfileController
    extends $AsyncNotifier<RecommendationProfile> {
  FutureOr<RecommendationProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<RecommendationProfile>, RecommendationProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RecommendationProfile>,
                RecommendationProfile
              >,
              AsyncValue<RecommendationProfile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
