import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/models/complete_quest_command.dart';
import '../../application/models/complete_quest_result.dart';
import 'quest_query_providers.dart';
import 'quest_repository_providers.dart';

part 'complete_quest_controller.g.dart';

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
@Riverpod(keepAlive: true)
class CompleteQuestController extends _$CompleteQuestController {
  @override
  FutureOr<CompleteQuestResult?> build() => null;

  Future<void> complete(CompleteQuestCommand command) async {
    if (state.isLoading) return; // a completion is already in flight

    state = const AsyncValue.loading();
    final useCase = ref.read(completeQuestUseCaseProvider);
    final result = await useCase.execute(command);

    switch (result) {
      case Ok(value: final value):
        state = AsyncValue.data(value);
        _invalidateAffected(command);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle, ready for a future completion.
  void reset() {
    state = const AsyncValue.data(null);
  }

  /// Invalidates only what a successful completion can have changed: this
  /// quest's progress and ledger rows for [command.date], plus the two
  /// lifetime-derived XP providers. Nothing else — completing a quest never
  /// changes the quest list itself (`CompleteQuestUseCase` never writes
  /// through `QuestRepository`).
  void _invalidateAffected(CompleteQuestCommand command) {
    final date = DateTime.utc(
      command.date.year,
      command.date.month,
      command.date.day,
    );
    ref.invalidate(questProgressForDateProvider(command.questId, date));
    ref.invalidate(
      xpTransactionsForQuestAndDateProvider(command.questId, date),
    );
    ref.invalidate(totalXpProvider);
    ref.invalidate(xpByAttributeProvider);
  }
}
