import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../quests/application/models/complete_quest_result.dart';
import '../../../quests/application/models/update_quest_progress_result.dart';
import '../../../quests/presentation/providers/complete_quest_controller.dart';
import '../../../quests/presentation/providers/quest_progress_controller.dart';
import '../../domain/entities/achievement.dart';
import 'achievement_query_providers.dart';
import 'achievement_repository_providers.dart';

part 'achievement_evaluation_controller.g.dart';

/// [pendingUnlocks] is a queue, not a single event (unlike `LevelUpEvent`'s
/// widen-in-place merge): one quest completion can unlock several distinct
/// achievements at once (Phase 10 correctness rule: "one quest completion
/// may unlock multiple achievements safely"), and each deserves its own
/// dialog rather than being flattened into one.
class AchievementEvaluationState {
  final List<Achievement> pendingUnlocks;

  const AchievementEvaluationState({this.pendingUnlocks = const []});

  AchievementEvaluationState copyWith({List<Achievement>? pendingUnlocks}) {
    return AchievementEvaluationState(
      pendingUnlocks: pendingUnlocks ?? this.pendingUnlocks,
    );
  }
}

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
@Riverpod(keepAlive: true)
class AchievementEvaluationController
    extends _$AchievementEvaluationController {
  @override
  AchievementEvaluationState build() {
    ref.listen<AsyncValue<CompleteQuestResult?>>(
      completeQuestControllerProvider,
      (previous, next) {
        if (next.hasValue && next.value != null) _evaluate();
      },
    );
    ref.listen<AsyncValue<UpdateQuestProgressResult?>>(
      questProgressControllerProvider,
      (previous, next) {
        if (next.hasValue && next.value?.completionResult != null) {
          _evaluate();
        }
      },
    );

    // Fire-and-forget: a build() method must return synchronously, and this
    // is a background catch-up pass, not something the first frame needs to
    // block on (mirrors quest_form.dart's `Future.microtask` pattern for
    // post-build side effects).
    Future.microtask(_evaluate);

    return const AchievementEvaluationState();
  }

  /// Achievement evaluation is a secondary concern layered on top of quest
  /// completion — a failure here (e.g. the achievement box somehow not
  /// being available) must never surface as an uncaught error out of a
  /// fire-and-forget microtask/listener callback and take down whatever
  /// unrelated flow triggered it. Every failure path is swallowed after a
  /// debug log, exactly like this codebase's existing `.when(error: ...)`
  /// widgets do for the same reason.
  Future<void> _evaluate() async {
    List<Achievement> unlocked = const [];
    try {
      final useCase = ref.read(evaluateAndUnlockAchievementsUseCaseProvider);
      final result = await useCase.execute();
      switch (result) {
        case Ok(value: final achievements):
          unlocked = achievements;
        case Err(failure: final failure):
          debugPrint('Achievement evaluation failed: $failure');
      }
    } catch (e) {
      debugPrint('Achievement evaluation failed: $e');
      return;
    }
    if (unlocked.isEmpty) return;

    state = state.copyWith(
      pendingUnlocks: [...state.pendingUnlocks, ...unlocked],
    );
    // The unlock list itself is stream-backed (watchAchievementUnlocksProvider
    // watches the Hive box directly) and updates on its own; only the
    // locked-achievements progress numbers need an explicit nudge, since
    // they're derived from a plain (non-stream) ledger snapshot.
    ref.invalidate(lockedAchievementsProvider);
  }

  /// Pops the front of the queue — called once the UI has shown (and
  /// dismissed) a dialog for it. Idempotent on an empty queue.
  void acknowledgeFirst() {
    if (state.pendingUnlocks.isEmpty) return;
    state = state.copyWith(
      pendingUnlocks: state.pendingUnlocks.skip(1).toList(),
    );
  }
}
