import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/services/quest_occurrence_policy.dart';
import '../../domain/services/quest_progress_policy.dart';
import '../models/complete_quest_command.dart';
import '../models/update_quest_progress_command.dart';
import '../models/update_quest_progress_result.dart';
import 'complete_quest_use_case.dart';

/// Moves a quest's progress for its current occurrence by one
/// increment/decrement/binary completion step. This is the write path
/// Phase 8 adds for quantity and duration quests (binary quests keep using
/// [CompleteQuestUseCase] directly via the existing
/// `CompleteQuestButton`/`CompleteQuestController` — see this class's own
/// doc for why `QuestProgressPolicy.nextValue` still accepts `complete` as a
/// binary operation regardless: it keeps the policy itself type-complete
/// even though this use case's only caller currently exercises it for
/// quantity/duration).
///
/// ## Occurrence anchor date (Phase 9)
/// [command]'s `date` is a nominal calendar day (typically "today"), not
/// necessarily the key `QuestProgress` is read/written under: this use case
/// resolves it through [QuestOccurrencePolicy.resolve] first, exactly like
/// [CompleteQuestUseCase] does, so both use cases agree on the same
/// occurrence anchor for the same `(quest, instant)` pair. For `weekly`
/// quests that anchor is the ISO week's Monday, which is what makes a
/// quantity/duration quest's progress accumulate across the whole week
/// instead of resetting on every distinct calendar day.
///
/// ## Completion delegation — the only correctness-critical part
/// [CompleteQuestUseCase] remains the *sole* authority that ever writes an
/// `XpTransaction` or decides how much XP a completion is worth (CLAUDE.md:
/// XP transactions are immutable and append-only; docs/architecture.md's
/// anti-abuse formula lives entirely in `QuestXpCalculator`). This use case
/// never computes XP — it only decides *whether* today's mutation is the
/// one that newly crosses the target, and if so, delegates the entire
/// completion (XP + the resulting `QuestProgress` write) to
/// [CompleteQuestUseCase].
///
/// "Newly crosses" is defined as: the *stored* `QuestProgress.isComplete`
/// for today was `false` (or no row exists yet) **before** this mutation,
/// and the freshly computed value is `>= target` **after** it. This one
/// rule is what makes every one of the following hold simultaneously,
/// without inventing any new domain concept:
/// - Reaching target awards XP exactly once: the transition only exists at
///   the moment `isComplete` flips false → true.
/// - Repeated taps after reaching target never duplicate XP: once
///   `isComplete` is `true`, further increments are clamped (see
///   [QuestProgressPolicy]) and never re-cross false → true, so this use
///   case simply persists the (unchanged) value itself instead of calling
///   [CompleteQuestUseCase] again.
/// - Decrementing after completion does not erase XP history: a decrement
///   only ever calls [QuestProgressRepository.upsert] with a lower
///   `progressValue`/`isComplete: false`; it never touches the ledger, and
///   `XpTransaction` rows are never deleted or rewritten anywhere in this
///   codebase.
/// - Re-reaching the target after such a decrement *does* call
///   [CompleteQuestUseCase] again — this use case does not itself decide
///   whether that second call is allowed to pay out. **Correction (Phase 8
///   follow-up):** an earlier version of this comment claimed this was
///   always safe because `CompleteQuestUseCase` prices same-occurrence
///   repeats at a diminishing (never duplicated) rate. That's true for
///   *repeatable* quests, but for a `Repeatability.none` (one-time) quest —
///   it let a decrement-then-reincrement (same occurrence, or even a later
///   one) earn a second, diminished-but-nonzero `XpTransaction`,
///   which violates "a non-repeatable completed quest cannot be rewarded
///   again". `CompleteQuestUseCase` now gates this itself (see its class
///   doc), reading the ledger — not `QuestProgress` — as the lifetime
///   completion record, since `QuestProgress.isComplete` is exactly what a
///   decrement rewrites back to `false`. This use case's job is unchanged:
///   detect the local `false → true` transition and delegate; whether that
///   delegated call is actually allowed to pay out is now
///   `CompleteQuestUseCase`'s call, and any rejection (`Err`) propagates
///   through this use case's `switch` below without persisting any
///   progress change.
class UpdateQuestProgressUseCase {
  const UpdateQuestProgressUseCase({
    required QuestRepository questRepository,
    required QuestProgressRepository questProgressRepository,
    required CompleteQuestUseCase completeQuestUseCase,
    QuestProgressPolicy policy = const QuestProgressPolicy(),
    QuestOccurrencePolicy occurrencePolicy = const QuestOccurrencePolicy(),
  }) : _questRepository = questRepository,
       _questProgressRepository = questProgressRepository,
       _completeQuestUseCase = completeQuestUseCase,
       _policy = policy,
       _occurrencePolicy = occurrencePolicy;

  final QuestRepository _questRepository;
  final QuestProgressRepository _questProgressRepository;
  final CompleteQuestUseCase _completeQuestUseCase;
  final QuestProgressPolicy _policy;
  final QuestOccurrencePolicy _occurrencePolicy;

  Future<Result<UpdateQuestProgressResult>> execute(
    UpdateQuestProgressCommand command,
  ) async {
    final Quest? quest;
    try {
      quest = await _questRepository.getById(command.questId);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load quest: $e'));
    }
    if (quest == null) {
      return Err(NotFoundFailure('Quest "${command.questId}" was not found'));
    }
    if (quest.state == QuestCompletionState.expired ||
        quest.state == QuestCompletionState.converted) {
      return Err(
        InvalidStateFailure(
          'Quest "${quest.id}" cannot be progressed while in state '
          '${quest.state.name}',
        ),
      );
    }

    final date = _occurrencePolicy
        .resolve(repeatability: quest.repeatability, instant: command.date)
        .anchorDate;
    final QuestProgress? existing;
    try {
      existing = await _questProgressRepository.getForQuestAndDate(
        quest.id,
        date,
      );
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load progress: $e'));
    }
    final previousValue = existing?.progressValue ?? 0.0;
    final wasComplete = existing?.isComplete ?? false;

    final nextResult = _policy.nextValue(
      progressType: quest.progressType,
      operation: command.operation,
      currentValue: previousValue,
      targetValue: quest.targetProgress,
      amount: command.amount,
    );
    if (nextResult is Err<double>) {
      return Err(nextResult.failure);
    }
    final newValue = (nextResult as Ok<double>).value;
    final willBeComplete = _policy.isTargetReached(
      newValue,
      quest.targetProgress,
    );
    final newlyCompleted = willBeComplete && !wasComplete;

    if (newlyCompleted) {
      final completionResult = await _completeQuestUseCase.execute(
        CompleteQuestCommand(
          questId: quest.id,
          date: date,
          progressValue: newValue,
        ),
      );
      return switch (completionResult) {
        Ok(value: final completion) => Ok(
          UpdateQuestProgressResult(
            previousProgress: previousValue,
            newProgress: newValue,
            completed: true,
            completionResult: completion,
          ),
        ),
        Err(failure: final failure) => Err(failure),
      };
    }

    final updated = QuestProgress(
      questId: quest.id,
      date: date,
      progressValue: newValue,
      isComplete: willBeComplete,
      notes: existing?.notes,
      qualityRating: existing?.qualityRating,
      timeSpent: existing?.timeSpent,
    );
    try {
      await _questProgressRepository.upsert(updated);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to save progress: $e'));
    }

    return Ok(
      UpdateQuestProgressResult(
        previousProgress: previousValue,
        newProgress: newValue,
        completed: false,
      ),
    );
  }
}
