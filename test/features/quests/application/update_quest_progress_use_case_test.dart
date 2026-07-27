import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/clock.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/models/update_quest_progress_command.dart';
import 'package:prime/features/quests/application/models/update_quest_progress_result.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/update_quest_progress_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/domain/repositories/quest_progress_repository.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';
import 'package:prime/features/quests/domain/services/quest_progress_policy.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

class _FakeQuestRepository implements QuestRepository {
  final Map<String, Quest> quests = {};
  Object? getByIdError;

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async {
    if (getByIdError != null) throw getByIdError!;
    return quests[id];
  }

  @override
  Stream<List<Quest>> watchAll() => Stream.value(quests.values.toList());

  @override
  Future<void> upsert(Quest quest) async => quests[quest.id] = quest;

  @override
  Future<void> deleteById(String id) async => quests.remove(id);
}

class _FakeQuestProgressRepository implements QuestProgressRepository {
  final Map<String, QuestProgress> entries = {};
  Object? upsertError;
  final List<QuestProgress> upsertCalls = [];

  String _key(String questId, DateTime date) =>
      '$questId|${date.year}-${date.month}-${date.day}';

  @override
  Future<QuestProgress?> getForQuestAndDate(
    String questId,
    DateTime date,
  ) async => entries[_key(questId, date)];

  @override
  Future<List<QuestProgress>> getForQuest(String questId) async =>
      entries.values.where((e) => e.questId == questId).toList();

  @override
  Future<void> upsert(QuestProgress progress) async {
    upsertCalls.add(progress);
    if (upsertError != null) throw upsertError!;
    entries[_key(progress.questId, progress.date)] = progress;
  }

  @override
  Future<void> deleteAllForQuest(String questId) async {
    entries.removeWhere((key, value) => value.questId == questId);
  }
}

class _FakeXpLedgerRepository implements XpLedgerRepository {
  final Map<String, XpTransaction> byKey = {};

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
    for (final t in transactions) {
      byKey.putIfAbsent(t.idempotencyKey, () => t);
    }
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    final prefix = '$questId|${_dateKey(date)}|';
    return byKey.values.where((t) => t.sourceId.startsWith(prefix)).toList();
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuest(String questId) async {
    final prefix = '$questId|';
    return byKey.values.where((t) => t.sourceId.startsWith(prefix)).toList();
  }

  @override
  Future<List<XpTransaction>> getTransactionsForDate(DateTime date) async {
    final dateKey = _dateKey(date);
    return byKey.values
        .where((t) => t.sourceId.split('|').elementAtOrNull(1) == dateKey)
        .toList();
  }

  @override
  Future<List<XpTransaction>> getAll() async => byKey.values.toList();

  @override
  Future<int> sumLifetimeXp() async =>
      byKey.values.fold<int>(0, (sum, t) => sum + t.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async => byKey.values
      .where((t) => t.attribute == type)
      .fold<int>(0, (sum, t) => sum + t.finalXp);

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class _FakeClock implements Clock {
  _FakeClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

Quest _buildQuest({
  String id = 'q1',
  ProgressType progressType = ProgressType.quantity,
  double targetProgress = 8,
  QuestCompletionState state = QuestCompletionState.notStarted,
  Repeatability repeatability = Repeatability.none,
}) {
  return Quest(
    id: id,
    title: 'Drink water',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 80},
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
    repeatability: repeatability,
  );
}

void main() {
  late _FakeQuestRepository questRepository;
  late _FakeQuestProgressRepository progressRepository;
  late _FakeXpLedgerRepository ledgerRepository;
  late UpdateQuestProgressUseCase useCase;
  final today = DateTime.utc(2026, 1, 10);

  setUp(() {
    questRepository = _FakeQuestRepository();
    progressRepository = _FakeQuestProgressRepository();
    ledgerRepository = _FakeXpLedgerRepository();
    useCase = UpdateQuestProgressUseCase(
      questRepository: questRepository,
      questProgressRepository: progressRepository,
      completeQuestUseCase: CompleteQuestUseCase(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: ledgerRepository,
        occurrenceService: QuestOccurrenceService(
          xpLedgerRepository: ledgerRepository,
        ),
        clock: _FakeClock(today),
      ),
    );
  });

  test('a missing quest returns NotFoundFailure', () async {
    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'missing',
        date: today,
        operation: QuestProgressOperation.increment,
      ),
    );

    expect(result, isA<Err<UpdateQuestProgressResult>>());
    expect(
      (result as Err<UpdateQuestProgressResult>).failure,
      isA<NotFoundFailure>(),
    );
  });

  test('initializes progress from zero when none exists yet', () async {
    questRepository.quests['q1'] = _buildQuest();

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
      ),
    );

    final value = (result as Ok<UpdateQuestProgressResult>).value;
    expect(value.previousProgress, 0);
    expect(value.newProgress, 1);
    expect(value.completed, isFalse);
  });

  test('persists the updated progress value', () async {
    questRepository.quests['q1'] = _buildQuest();

    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 3,
      ),
    );

    final stored = await progressRepository.getForQuestAndDate('q1', today);
    expect(stored!.progressValue, 3);
    expect(stored.isComplete, isFalse);
  });

  test(
    'reaching the target delegates completion to CompleteQuestUseCase, awarding XP exactly once',
    () async {
      questRepository.quests['q1'] = _buildQuest(targetProgress: 8);

      final result = await useCase.execute(
        UpdateQuestProgressCommand(
          questId: 'q1',
          date: today,
          operation: QuestProgressOperation.increment,
          amount: 8,
        ),
      );

      final value = (result as Ok<UpdateQuestProgressResult>).value;
      expect(value.completed, isTrue);
      expect(value.completionResult, isA<CompleteQuestResult>());
      expect(value.completionResult!.totalXpAwarded, greaterThan(0));

      final stored = await progressRepository.getForQuestAndDate('q1', today);
      expect(stored!.isComplete, isTrue);
      expect(ledgerRepository.byKey.length, 1); // one attribute transaction
    },
  );

  test('non-repeatable quest: repeated increments while already at target do '
      'not create a second XP transaction', () async {
    // repeatability is Repeatability.none — non-repeatable, per the only
    // repeatability signal the domain model wires up anywhere.
    questRepository.quests['q1'] = _buildQuest(targetProgress: 8);

    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    final xpAfterFirst = await ledgerRepository.sumLifetimeXp();

    // Already at target — further increments clamp and must not
    // re-trigger CompleteQuestUseCase.
    final second = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 1,
      ),
    );

    final value = (second as Ok<UpdateQuestProgressResult>).value;
    expect(value.completed, isFalse);
    expect(value.completionResult, isNull);
    expect(await ledgerRepository.sumLifetimeXp(), xpAfterFirst);
    expect(ledgerRepository.byKey.length, 1);
  });

  test('decrementing after completion does not erase XP history', () async {
    questRepository.quests['q1'] = _buildQuest(targetProgress: 8);
    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    final xpAfterCompletion = await ledgerRepository.sumLifetimeXp();
    expect(xpAfterCompletion, greaterThan(0));

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.decrement,
        amount: 3,
      ),
    );

    final value = (result as Ok<UpdateQuestProgressResult>).value;
    expect(value.newProgress, 5);
    expect(value.completed, isFalse);
    // The ledger is untouched — decrementing never deletes/rewrites XP.
    expect(await ledgerRepository.sumLifetimeXp(), xpAfterCompletion);
    final stored = await progressRepository.getForQuestAndDate('q1', today);
    expect(stored!.isComplete, isFalse);
  });

  test('non-repeatable quest: decrementing after completion and re-reaching '
      'the target does not append a second XP transaction', () async {
    // Correction test (Phase 8 follow-up): this scenario used to
    // re-trigger CompleteQuestUseCase and award diminished-but-nonzero
    // XP a second time, because "first completion ever" was derived from
    // QuestProgress history, which the decrement itself had just
    // rewritten back to `isComplete: false`. A quest with no
    // repeatability is Repeatability.none (one-time) and must never be rewarded twice for
    // its lifetime, regardless of how the target is re-reached.
    questRepository.quests['q1'] = _buildQuest(targetProgress: 8);
    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    final xpAfterFirst = await ledgerRepository.sumLifetimeXp();
    expect(xpAfterFirst, greaterThan(0));

    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.decrement,
        amount: 8,
      ),
    );
    final second = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );

    expect(second, isA<Err<UpdateQuestProgressResult>>());
    expect(
      (second as Err<UpdateQuestProgressResult>).failure,
      isA<InvalidStateFailure>(),
    );
    // No new transaction, no lifetime XP change, and the rejected
    // mutation persisted nothing — progress stays at the decremented
    // (pre-attempt) value rather than silently jumping to "at target".
    expect(ledgerRepository.byKey.length, 1);
    expect(await ledgerRepository.sumLifetimeXp(), xpAfterFirst);
    final stored = await progressRepository.getForQuestAndDate('q1', today);
    expect(stored!.progressValue, 0);
    expect(stored.isComplete, isFalse);
  });

  test('repeatable (daily) quest: decrementing and re-incrementing within the '
      'same day earns the existing diminishing-returns rate, never a full '
      'duplicate of the first award', () async {
    questRepository.quests['q1'] = _buildQuest(
      targetProgress: 8,
      repeatability: Repeatability.daily,
    );
    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    // 80 base xp * 1.25 first-completion bonus = 100.
    final firstAward = ledgerRepository.byKey.values.single.finalXp;
    expect(firstAward, 100);

    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.decrement,
        amount: 8,
      ),
    );
    final second = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );

    final value = (second as Ok<UpdateQuestProgressResult>).value;
    expect(value.completed, isTrue);
    // 80 base xp * no first-completion bonus (already awarded, ledger
    // correctly remembers it despite the decrement) * 0.5 same-day
    // diminishing returns = 40 — not zero, and not another 100.
    expect(value.completionResult!.totalXpAwarded, 40);
    expect(ledgerRepository.byKey.length, 2);
    expect(await ledgerRepository.sumLifetimeXp(), firstAward + 40);
  });

  test('repeatable (daily) quest: a genuinely new day is a new occurrence and '
      'is rewarded again', () async {
    questRepository.quests['q1'] = _buildQuest(
      targetProgress: 8,
      repeatability: Repeatability.daily,
    );
    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    final firstAward = ledgerRepository.byKey.values.single.finalXp;
    expect(firstAward, 100);

    final tomorrow = today.add(const Duration(days: 1));
    final second = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: tomorrow,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );

    final value = (second as Ok<UpdateQuestProgressResult>).value;
    expect(value.completed, isTrue);
    // 80 base xp * no first-completion bonus (already earned once) * 1.02
    // one-day-streak consistency bonus, repeatIndexInOccurrence resets to 0 for
    // the new day so no diminishing returns applies = round(81.6) = 82.
    expect(value.completionResult!.totalXpAwarded, 82);
    expect(ledgerRepository.byKey.length, 2);
    expect(await ledgerRepository.sumLifetimeXp(), firstAward + 82);
  });

  test('repeatable (weekly) quest: quantity progress accumulates across '
      'the whole ISO week (not reset per day), then resets on the next '
      'ISO week', () async {
    // 2026-01-05 is a Monday (ISO week 2026-W02); 2026-01-07 is the
    // Wednesday of that same week; 2026-01-12 is the following Monday.
    final monday = DateTime.utc(2026, 1, 5);
    final wednesday = DateTime.utc(2026, 1, 7);
    final nextMonday = DateTime.utc(2026, 1, 12);
    questRepository.quests['q1'] = _buildQuest(
      targetProgress: 8,
      repeatability: Repeatability.weekly,
    );

    // Monday: +3.
    final afterMonday = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: monday,
        operation: QuestProgressOperation.increment,
        amount: 3,
      ),
    );
    expect((afterMonday as Ok<UpdateQuestProgressResult>).value.newProgress, 3);

    // Wednesday, same ISO week: reads back Monday's accumulated 3 and adds
    // 5 more, on top of it — not a fresh 0-based day.
    final afterWednesday = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: wednesday,
        operation: QuestProgressOperation.increment,
        amount: 5,
      ),
    );
    final wedValue = (afterWednesday as Ok<UpdateQuestProgressResult>).value;
    expect(wedValue.previousProgress, 3); // continued from Monday, not 0
    expect(wedValue.newProgress, 8);
    expect(wedValue.completed, isTrue);

    // Both writes landed on the same (questId, Monday-anchor) row.
    final storedThisWeek = await progressRepository.getForQuestAndDate(
      'q1',
      monday,
    );
    expect(storedThisWeek!.progressValue, 8);
    expect(storedThisWeek.isComplete, isTrue);

    // The following Monday: a fresh ISO week — nothing written under that
    // anchor yet, so progress starts back at 0 rather than "already at 8".
    final afterNextWeek = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: nextMonday,
        operation: QuestProgressOperation.increment,
        amount: 2,
      ),
    );
    final nextWeekValue =
        (afterNextWeek as Ok<UpdateQuestProgressResult>).value;
    expect(nextWeekValue.previousProgress, 0); // reset
    expect(nextWeekValue.newProgress, 2);
    expect(nextWeekValue.completed, isFalse);
  });

  test('a quest in an expired state cannot be progressed', () async {
    questRepository.quests['q1'] = _buildQuest(
      state: QuestCompletionState.expired,
    );

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
      ),
    );

    expect(result, isA<Err<UpdateQuestProgressResult>>());
    expect(
      (result as Err<UpdateQuestProgressResult>).failure,
      isA<InvalidStateFailure>(),
    );
  });

  test(
    'an invalid operation for the progress type returns a Failure',
    () async {
      questRepository.quests['q1'] = _buildQuest(
        progressType: ProgressType.binary,
        targetProgress: 1,
      );

      final result = await useCase.execute(
        UpdateQuestProgressCommand(
          questId: 'q1',
          date: today,
          operation: QuestProgressOperation.increment,
        ),
      );

      expect(result, isA<Err<UpdateQuestProgressResult>>());
      expect(
        (result as Err<UpdateQuestProgressResult>).failure,
        isA<ValidationFailure>(),
      );
    },
  );

  test('a repository failure loading the quest returns a Failure', () async {
    questRepository.getByIdError = Exception('boom');

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
      ),
    );

    expect(result, isA<Err<UpdateQuestProgressResult>>());
    expect(
      (result as Err<UpdateQuestProgressResult>).failure,
      isA<UnexpectedFailure>(),
    );
  });

  test('a repository failure persisting progress returns a Failure', () async {
    questRepository.quests['q1'] = _buildQuest();
    progressRepository.upsertError = Exception('disk full');

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
      ),
    );

    expect(result, isA<Err<UpdateQuestProgressResult>>());
    expect(
      (result as Err<UpdateQuestProgressResult>).failure,
      isA<UnexpectedFailure>(),
    );
  });

  test('binary: complete jumps straight to the target and awards XP', () async {
    questRepository.quests['q1'] = _buildQuest(
      progressType: ProgressType.binary,
      targetProgress: 1,
    );

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.complete,
      ),
    );

    final value = (result as Ok<UpdateQuestProgressResult>).value;
    expect(value.completed, isTrue);
    expect(value.newProgress, 1);
  });
}
