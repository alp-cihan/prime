import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../quests/application/models/complete_quest_result.dart';
import '../../../quests/application/models/update_quest_progress_result.dart';
import '../../../quests/presentation/providers/complete_quest_controller.dart';
import '../../../quests/presentation/providers/quest_progress_controller.dart';
import '../../domain/entities/chain.dart';
import 'chain_repository_providers.dart';

part 'chain_evaluation_controller.g.dart';

/// [recentlyCompleted] is simply the most recent evaluation pass's newly-
/// completed chains — a plain replace, not a queue: unlike achievements'
/// unlock dialog, this phase adds no chain-completion celebration UI (see
/// the Phase 11 non-goals), so nothing needs to dequeue it one at a time.
/// It exists mainly for test observability and as the hook a future
/// notification/dialog could read from without any controller changes.
class ChainEvaluationState {
  final List<Chain> recentlyCompleted;

  const ChainEvaluationState({this.recentlyCompleted = const []});
}

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
@Riverpod(keepAlive: true)
class ChainEvaluationController extends _$ChainEvaluationController {
  @override
  ChainEvaluationState build() {
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

    // Fire-and-forget background catch-up pass — see
    // `AchievementEvaluationController`'s identical doc for why this is
    // safe to not await from build().
    Future.microtask(_evaluate);

    return const ChainEvaluationState();
  }

  /// Chain evaluation is a secondary concern layered on top of quest
  /// completion — a failure here must never surface as an uncaught error
  /// out of a fire-and-forget microtask/listener callback and take down
  /// whatever unrelated flow triggered it (this is the exact robustness
  /// gap `AchievementEvaluationController` had to be fixed for in Phase 10;
  /// applied here from the start).
  Future<void> _evaluate() async {
    List<Chain> completed = const [];
    try {
      final useCase = ref.read(evaluateAndAdvanceChainsUseCaseProvider);
      final result = await useCase.execute();
      switch (result) {
        case Ok(value: final chains):
          completed = chains;
        case Err(failure: final failure):
          debugPrint('Chain evaluation failed: $failure');
      }
    } catch (e) {
      debugPrint('Chain evaluation failed: $e');
      return;
    }

    // This controller can be disposed while `execute()` above was still
    // in flight (e.g. a test container disposed right after `build()`
    // kicked off the fire-and-forget boot-time pass) — writing to `state`
    // after that throws, so this checks `ref.mounted` first rather than
    // assuming the awaited gap above was safe to return into.
    if (!ref.mounted) return;
    state = ChainEvaluationState(recentlyCompleted: completed);
    // The progress list itself is stream-backed
    // (watchAllChainProgressProvider watches the Hive box directly) and
    // updates on its own; nothing else needs an explicit invalidation.
  }
}
