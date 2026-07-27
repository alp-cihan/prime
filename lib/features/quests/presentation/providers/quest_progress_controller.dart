import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/result.dart';
import '../../../xp_ledger/presentation/providers/xp_ledger_providers.dart';
import '../../application/models/update_quest_progress_command.dart';
import '../../application/models/update_quest_progress_result.dart';
import '../../domain/services/quest_progress_policy.dart';
import 'quest_query_providers.dart';
import 'quest_repository_providers.dart';

part 'quest_progress_controller.g.dart';

/// Drives quantity/duration progress mutations through
/// [UpdateQuestProgressUseCase] and exposes the outcome as an
/// [AsyncValue] — the same idle/loading/success/error shape as every other
/// controller in this feature (`CompleteQuestController`,
/// `QuestFormController`, `DeleteQuestController`):
/// - idle: `AsyncData(null)` (the initial state, and after [reset]).
/// - submitting: `AsyncLoading()`, set synchronously before the use case
///   runs — the guard below turns an overlapping call into a no-op, so a
///   rapid double-tap on `+`/`-` can never submit two mutations at once.
/// - success: `AsyncData(UpdateQuestProgressResult)`.
/// - error: `AsyncError(Failure, StackTrace)`.
///
/// Binary quests are deliberately **not** routed through this controller —
/// they keep using the existing, already-tested
/// `CompleteQuestController`/`CompleteQuestButton` pair directly. See
/// `quest_detail_page.dart` for where that split is made.
///
/// `keepAlive: true` for the same reason as the other controllers: an
/// autoDispose default would let this get torn down mid-`await` the moment
/// its last watcher unmounts, silently losing the outcome of a mutation the
/// user is very likely to check (e.g. after a quick navigation).
@Riverpod(keepAlive: true)
class QuestProgressController extends _$QuestProgressController {
  @override
  FutureOr<UpdateQuestProgressResult?> build() => null;

  Future<void> increment(String questId, DateTime date, {double amount = 1}) =>
      _run(
        UpdateQuestProgressCommand(
          questId: questId,
          date: date,
          operation: QuestProgressOperation.increment,
          amount: amount,
        ),
      );

  Future<void> decrement(String questId, DateTime date, {double amount = 1}) =>
      _run(
        UpdateQuestProgressCommand(
          questId: questId,
          date: date,
          operation: QuestProgressOperation.decrement,
          amount: amount,
        ),
      );

  /// A positive [amount] increments, a negative one decrements — the single
  /// entry point the custom-amount field on the quantity controls uses.
  Future<void> addAmount(String questId, DateTime date, double amount) {
    if (amount < 0) {
      return decrement(questId, date, amount: -amount);
    }
    return increment(questId, date, amount: amount);
  }

  Future<void> _run(UpdateQuestProgressCommand command) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    final useCase = ref.read(updateQuestProgressUseCaseProvider);
    final result = await useCase.execute(command);

    switch (result) {
      case Ok(value: final value):
        state = AsyncValue.data(value);
        _invalidateAffected(command.questId, command.date, value.completed);
      case Err(failure: final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Returns to idle, ready for a future mutation.
  void reset() {
    state = const AsyncValue.data(null);
  }

  /// [questProgressForDateProvider] is a plain `Future` family (not
  /// stream-backed), so it always needs an explicit invalidation — every
  /// mutation changes it. The XP-ledger providers only need one when a
  /// completion actually happened; a plain increment/decrement never
  /// touches the ledger.
  void _invalidateAffected(String questId, DateTime date, bool completed) {
    final normalized = DateTime.utc(date.year, date.month, date.day);
    ref.invalidate(questProgressForDateProvider(questId, normalized));
    if (completed) {
      ref.invalidate(
        xpTransactionsForQuestAndDateProvider(questId, normalized),
      );
      ref.invalidate(xpTransactionsForDateProvider(normalized));
      ref.invalidate(totalXpProvider);
      ref.invalidate(xpByAttributeProvider);
    }
  }
}
