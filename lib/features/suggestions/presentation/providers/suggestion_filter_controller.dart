import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/recommendation_profile.dart';

part 'suggestion_filter_controller.g.dart';

/// Session-only goal-area filter chips on the Suggestions page — never
/// persisted (Phase 16: "Do not persist ranking results"), so it resets to
/// "no filter" every time the page is freshly opened. Default `autoDispose`
/// is exactly right here: once nothing watches it (the page is left), it's
/// gone.
@riverpod
class SuggestionFilterController extends _$SuggestionFilterController {
  @override
  Set<GoalArea> build() => const <GoalArea>{};

  void toggle(GoalArea goal) {
    state = state.contains(goal)
        ? ({...state}..remove(goal))
        : {...state, goal};
  }

  void clear() => state = const <GoalArea>{};
}
