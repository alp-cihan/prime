import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../../../core/persistence/hive_keys.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_progress.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../../domain/repositories/quest_repository.dart';
import '../../domain/services/quest_xp_calculator.dart';
import '../clock.dart';
import '../models/complete_quest_command.dart';
import '../models/complete_quest_result.dart';

/// Orchestrates one quest completion: loads the quest, derives every
/// XP-relevant history value from the repositories (never from the caller),
/// calls [QuestXpCalculator] exactly once at quest level, writes the
/// resulting ledger rows, and only then upserts today's [QuestProgress].
///
/// ## `XpTransaction.baseXp` — resolved semantics
/// docs/architecture.md §15 does not define what a per-attribute
/// `XpTransaction.baseXp` means once XP is calculated at the quest level and
/// distributed (§3.1 has no single per-attribute "base" once weights are
/// summed). The narrowest interpretation consistent with the rest of the
/// entity is: `baseXp` is the attribute's *original, pre-modifier* weight —
/// `quest.attributeXpWeights[attribute]` — while `finalXp` is that
/// attribute's *actual awarded* share after quest-level modifiers, the
/// diminishing-returns/daily-cap clamp, and allocation. This keeps `baseXp`
/// meaningful as "what this attribute was worth on this quest" (stable,
/// quest-definition data) and `finalXp` as "what you actually got" — exactly
/// the two numbers a "why did I get this XP" audit view (§16) needs, without
/// inventing any new economy rule.
///
/// ## `sourceId` / idempotency key — resolved format
/// §15's inline comment describes `sourceId` generically ("quest id, chain
/// milestone id, etc.") while §16 calls it "the QuestProgress completion
/// event id" and its example idempotency formula lists `sourceId` as an
/// input distinct from `questId`. `QuestProgress` has no separate per-event
/// id (it is one row per `(questId, date)`, upserted — see §17), so there is
/// no existing id to reuse. This use case constructs a deterministic
/// synthetic event id instead: `sourceId = "questId|dateKey|repeatIndex"`.
/// All attribute rows from one completion share this `sourceId` (§16), and
/// counting *distinct* `sourceId`s already on the ledger for a given day is
/// exactly how [repeatIndexToday] is derived for the next completion — so
/// the format is self-supporting and needs no additional repository state.
/// `idempotencyKey = "questId|attributeName|dateKey|repeatIndex"` follows
/// the same components; retrying the exact same completion recomputes the
/// same key, and [XpLedgerRepository.appendAll]'s documented "skip existing
/// keys" contract makes that retry a no-op. `XpTransaction.id` reuses the
/// idempotency key — it is already a unique, deterministic string for this
/// row, so generating a separate random id would add nothing.
///
/// ## Non-repeatable completion is gated for the quest's whole lifetime
/// A quest with `repeatabilityRule == null` may earn completion XP at most
/// once, ever — reached via any path (a fresh completion, or re-reaching
/// the target after a Phase 8 progress decrement, same day or a later day).
/// This is checked here, in the one place that ever writes XP, rather than
/// in `UpdateQuestProgressUseCase`, precisely so every caller (binary
/// complete, quantity/duration auto-complete) is protected uniformly. The
/// check reads [XpLedgerRepository.getTransactionsForQuest] — the ledger,
/// not `QuestProgress` — because ledger rows are append-only while
/// `QuestProgress` is upserted per day and can have `isComplete` rewritten
/// back to `false` by a later decrement.
class CompleteQuestUseCase {
  const CompleteQuestUseCase({
    required QuestRepository questRepository,
    required QuestProgressRepository questProgressRepository,
    required XpLedgerRepository xpLedgerRepository,
    QuestXpCalculator calculator = const QuestXpCalculator(),
    Clock clock = const SystemClock(),
  }) : _questRepository = questRepository,
       _questProgressRepository = questProgressRepository,
       _xpLedgerRepository = xpLedgerRepository,
       _calculator = calculator,
       _clock = clock;

  final QuestRepository _questRepository;
  final QuestProgressRepository _questProgressRepository;
  final XpLedgerRepository _xpLedgerRepository;
  final QuestXpCalculator _calculator;
  final Clock _clock;

  Future<Result<CompleteQuestResult>> execute(
    CompleteQuestCommand command,
  ) async {
    // 1-2. Load the quest; reject if missing.
    final quest = await _questRepository.getById(command.questId);
    if (quest == null) {
      return Err(NotFoundFailure('Quest "${command.questId}" was not found'));
    }

    // 3. Validate the quest can be completed at all right now.
    final stateFailure = _validateCompletable(quest);
    if (stateFailure != null) {
      return Err(stateFailure);
    }

    final date = _normalizeDate(command.date);
    final dateKey = HiveKeys.dateKey(date);

    // 4. Read today's existing progress (if any) for this quest/date.
    final existingProgress = await _questProgressRepository.getForQuestAndDate(
      quest.id,
      date,
    );

    // 5. Read today's existing XP transactions for this quest.
    final todaysTransactions = await _xpLedgerRepository
        .getTransactionsForQuestAndDate(quest.id, date);

    // 6. Derive priorXpEarnedTodayForQuest and repeatIndexToday from ledger
    // history — never from caller input.
    final priorXpEarnedTodayForQuest = todaysTransactions.fold<int>(
      0,
      (sum, t) => sum + t.finalXp,
    );
    final repeatIndexToday = todaysTransactions
        .map((t) => t.sourceId)
        .toSet()
        .length;

    // 6b. Lifetime ledger history for this quest — the append-only source
    // of truth for "has this quest ever earned completion XP". Deliberately
    // read from the ledger, not from QuestProgress: progress rows are
    // upserted per day and a later decrement can rewrite a day's
    // `isComplete` back to false, which would make a progress-history-based
    // check forget a completion that already paid out. See
    // `HiveKeys.xpSourceIdQuestPrefix` for why the ledger doesn't have this
    // problem.
    final priorTransactionsForQuest = await _xpLedgerRepository
        .getTransactionsForQuest(quest.id);
    final hasEverBeenAwardedXp = priorTransactionsForQuest.isNotEmpty;
    final isFirstCompletionEver = !hasEverBeenAwardedXp;

    // 6c. A quest with no `repeatabilityRule` is one-time: once it has ever
    // earned XP, it can never earn XP again, regardless of same-day
    // decrements or later-day re-attempts. This is the only repeatability
    // signal currently wired to anything in the domain model (the create/
    // edit form's "Repeats" field writes it, and nothing else — see
    // `QuestType.repeatable`'s doc comment — expresses an occurrence rule).
    // A `repeatabilityRule` of `daily` is intentionally left ungated here:
    // the existing per-day `repeatIndexToday`/diminishing-returns mechanism
    // (docs/architecture.md §3.3) already prices repeats within one day,
    // and a new calendar day is a genuinely new, already-safely-modeled
    // occurrence. `weekly` has no enforced occurrence boundary anywhere in
    // this codebase (no week-start/last-occurrence concept exists), so it
    // is also left ungated rather than inventing one — see the Phase 8
    // correction report for why this is flagged, not fixed.
    if (quest.repeatabilityRule == null && hasEverBeenAwardedXp) {
      return Err(
        InvalidStateFailure(
          'Quest "${quest.id}" is not repeatable and has already been '
          'completed — it cannot be rewarded again.',
        ),
      );
    }

    // 7. Determine the consecutive-day streak from this quest's full
    // progress history.
    final history = await _questProgressRepository.getForQuest(quest.id);
    final consecutiveDayStreak = _consecutiveDayStreak(history, date);

    final completionRatio = quest.progressType == ProgressType.binary
        ? 1.0
        : (command.progressValue / quest.targetProgress).clamp(0.0, 1.0);

    // 8. Call the calculator exactly once, at quest level.
    final calculation = _calculator.calculate(
      attributeXpWeights: quest.attributeXpWeights,
      difficulty: quest.difficulty,
      completionRatio: completionRatio,
      consecutiveDayStreak: consecutiveDayStreak,
      qualityRating: command.qualityRating,
      repeatIndexToday: repeatIndexToday,
      priorXpEarnedTodayForQuest: priorXpEarnedTodayForQuest,
      isFirstCompletionEver: isFirstCompletionEver,
    );
    if (calculation is Err<QuestXpAllocation>) {
      // Calculation failed validation — propagate as-is. Nothing has been
      // written yet, so this cannot leave a partial write behind.
      return Err(calculation.failure);
    }
    final allocation = (calculation as Ok<QuestXpAllocation>).value;

    // 9-10. Build immutable XpTransaction rows with deterministic ids and
    // idempotency keys (see class doc for the exact format).
    final sourceId = '${quest.id}|$dateKey|$repeatIndexToday';
    final createdAt = _clock.now();
    final transactions = [
      for (final entry in allocation.xpByAttribute.entries)
        XpTransaction(
          id: '$sourceId|${entry.key.name}',
          sourceType: XpSourceType.quest,
          sourceId: sourceId,
          attribute: entry.key,
          baseXp: quest.attributeXpWeights[entry.key] ?? 0,
          modifiersApplied: allocation.modifiersApplied,
          finalXp: entry.value,
          createdAt: createdAt,
          idempotencyKey:
              '${quest.id}|${entry.key.name}|$dateKey|$repeatIndexToday',
        ),
    ];

    // 11. Append through the ledger repository (append-only, idempotent by
    // key — a retry with the same key is a no-op there).
    await _xpLedgerRepository.appendAll(transactions);

    // 12. Only now — after validation, calculation, and the ledger write all
    // succeeded — upsert QuestProgress.
    final updatedProgress = QuestProgress(
      questId: quest.id,
      date: date,
      progressValue: quest.progressType == ProgressType.binary
          ? quest.targetProgress
          : command.progressValue,
      isComplete: completionRatio >= 1.0,
      notes: command.notes ?? existingProgress?.notes,
      qualityRating: command.qualityRating,
      timeSpent: command.timeSpent,
    );
    await _questProgressRepository.upsert(updatedProgress);

    // 13. Return a useful result.
    final dailyCap = _dailyCap(quest, allocation.modifiersApplied);
    return Ok(
      CompleteQuestResult(
        progress: updatedProgress,
        transactions: transactions,
        totalXpAwarded: allocation.totalXp,
        xpByAttribute: allocation.xpByAttribute,
        firstCompletionBonusApplied:
            (allocation.modifiersApplied['firstCompletionBonus'] ?? 1.0) != 1.0,
        dailyCapLimited:
            priorXpEarnedTodayForQuest + allocation.totalXp >= dailyCap,
      ),
    );
  }

  Failure? _validateCompletable(Quest quest) {
    if (quest.state == QuestCompletionState.expired ||
        quest.state == QuestCompletionState.converted) {
      return InvalidStateFailure(
        'Quest "${quest.id}" cannot be completed while in state ${quest.state.name}',
      );
    }
    return null;
  }

  /// §3.3: `baseXp × difficultyMultiplier × 2`, at quest level — the total
  /// of the quest's attribute weights times the resolved difficulty
  /// multiplier (read back from the calculator's own reported modifiers, so
  /// this never drifts from what `QuestXpCalculator` actually used).
  int _dailyCap(Quest quest, Map<String, double> modifiersApplied) {
    final totalBaseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final difficultyMultiplier = modifiersApplied['difficulty'] ?? 1.0;
    return (totalBaseXp * difficultyMultiplier * 2).round();
  }

  int _consecutiveDayStreak(List<QuestProgress> history, DateTime date) {
    final completedDates = history
        .where((p) => p.isComplete)
        .map((p) => _normalizeDate(p.date))
        .toSet();
    var streak = 0;
    var cursor = date.subtract(const Duration(days: 1));
    while (completedDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Date-only, UTC-normalized — deterministic and free of local-timezone/
  /// DST drift, so `(questId, date)` comparisons are stable.
  DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}
