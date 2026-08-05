import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/recommendation_profile.dart';
import 'suggestions_providers.dart';

part 'recommendation_profile_controller.g.dart';

/// The single source of truth for the current [RecommendationProfile] —
/// loads it once on first watch, and every save flows back through this
/// controller so every other provider watching it (ranked suggestions, the
/// preferences editor) sees the update immediately.
///
/// `keepAlive: true` for the same reason as every other mutation controller
/// in this app (`QuestFormController` et al.): an autoDispose default would
/// let Riverpod tear this down mid-`await` the moment its last watcher
/// unmounts, silently losing a save the user is very likely to check again.
@Riverpod(keepAlive: true)
class RecommendationProfileController
    extends _$RecommendationProfileController {
  @override
  FutureOr<RecommendationProfile> build() {
    return ref.watch(loadRecommendationProfileUseCaseProvider).execute();
  }

  Future<void> save(RecommendationProfile profile) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(saveRecommendationProfileUseCaseProvider);
    final result = await useCase.execute(profile);

    switch (result) {
      case Ok(value: final saved):
        state = AsyncValue.data(saved);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
