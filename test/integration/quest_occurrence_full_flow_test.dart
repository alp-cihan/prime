import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

/// End-to-end occurrence-model coverage against real Hive boxes: one-time,
/// daily, and weekly quests, each carried through a full
/// complete → same-occurrence-repeat → new-occurrence lifecycle, verifying
/// ledger counts, XP totals, repeat indices, and progress reset at every
/// step. See `complete_quest_persistence_integration_test.dart` for the
/// pre-Phase-9 daily/retry coverage this builds on.
void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<Box<QuestHiveModel>> openQuestBox() =>
      Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
  Future<Box<QuestProgressHiveModel>> openProgressBox() =>
      Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
  Future<Box<XpTransactionHiveModel>> openLedgerBox() =>
      Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

  Quest buildQuest(Repeatability repeatability) {
    return Quest(
      id: 'q1',
      title: 'Test quest',
      description: '',
      type: QuestType.daily,
      difficulty: QuestDifficulty.normal,
      attributeXpWeights: const {AttributeType.health: 80},
      linkedIdentityStatementIds: const [],
      progressType: ProgressType.binary,
      currentProgress: 0,
      targetProgress: 1,
      prerequisiteQuestIds: const [],
      state: QuestCompletionState.notStarted,
      failureBehavior: FailureBehavior.expire,
      repeatability: repeatability,
    );
  }

  Future<CompleteQuestUseCase> buildUseCase() async {
    final ledgerRepository = HiveXpLedgerRepository(await openLedgerBox());
    return CompleteQuestUseCase(
      questRepository: HiveQuestRepository(await openQuestBox()),
      questProgressRepository: HiveQuestProgressRepository(
        await openProgressBox(),
      ),
      xpLedgerRepository: ledgerRepository,
      occurrenceService: QuestOccurrenceService(
        xpLedgerRepository: ledgerRepository,
      ),
    );
  }

  test('one-time quest: completed once, then permanently blocked on any '
      'future day', () async {
    await HiveQuestRepository(
      await openQuestBox(),
    ).upsert(buildQuest(Repeatability.none));
    final useCase = await buildUseCase();

    final first = await useCase.execute(
      CompleteQuestCommand(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      ),
    );
    expect(first, isA<Ok<CompleteQuestResult>>());

    final future = await useCase.execute(
      CompleteQuestCommand(
        questId: 'q1',
        date: DateTime.utc(2027, 3, 1), // a year later
        progressValue: 1,
      ),
    );
    expect(future, isA<Err<CompleteQuestResult>>());

    final ledgerRepository = HiveXpLedgerRepository(await openLedgerBox());
    expect(await ledgerRepository.sumLifetimeXp(), 100); // 80 * 1.25, once
  });

  test('daily quest: same-day repeats diminish, a new day is a fresh '
      'occurrence with progress reset and full eligibility', () async {
    await HiveQuestRepository(
      await openQuestBox(),
    ).upsert(buildQuest(Repeatability.daily));
    final useCase = await buildUseCase();
    final progressRepository = HiveQuestProgressRepository(
      await openProgressBox(),
    );
    final ledgerRepository = HiveXpLedgerRepository(await openLedgerBox());

    final day1 = DateTime.utc(2026, 1, 10);
    final first = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: day1, progressValue: 1),
    );
    final firstXp = (first as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(firstXp, 100); // 80 * 1.25 first-completion bonus

    // Same-day repeat: diminishing returns (repeat index 1 -> x0.5), not
    // blocked, not a duplicate of the first award.
    final secondSameDay = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: day1, progressValue: 1),
    );
    final secondXp =
        (secondSameDay as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(secondXp, 40); // 80 * 0.5, no first-completion bonus this time

    final progressDay1 = await progressRepository.getForQuestAndDate(
      'q1',
      day1,
    );
    expect(progressDay1!.isComplete, isTrue);

    // A genuinely new day: fresh occurrence. Progress for that new day
    // doesn't exist yet (reset by construction — nothing ever wrote to that
    // key), and the quest is fully eligible again (repeat index back to 0).
    final day2 = day1.add(const Duration(days: 1));
    final progressBeforeDay2 = await progressRepository.getForQuestAndDate(
      'q1',
      day2,
    );
    expect(progressBeforeDay2, isNull); // reset, lazily, by never existing

    final day2Result = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: day2, progressValue: 1),
    );
    final day2Xp = (day2Result as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(day2Xp, greaterThan(secondXp)); // not diminished — new occurrence

    expect(await ledgerRepository.sumLifetimeXp(), firstXp + secondXp + day2Xp);
    final allEntries = await ledgerRepository.getTransactionsForQuest('q1');
    final distinctCompletions = allEntries.map((t) => t.sourceId).toSet();
    expect(distinctCompletions.length, 3); // three genuinely separate awards
  });

  test('weekly quest: same-ISO-week repeats share one occurrence, the next '
      'ISO week is fresh with progress reset', () async {
    await HiveQuestRepository(
      await openQuestBox(),
    ).upsert(buildQuest(Repeatability.weekly));
    final useCase = await buildUseCase();
    final progressRepository = HiveQuestProgressRepository(
      await openProgressBox(),
    );
    final ledgerRepository = HiveXpLedgerRepository(await openLedgerBox());

    final monday = DateTime.utc(2026, 1, 5); // Monday, ISO week 2026-W02
    final wednesday = DateTime.utc(2026, 1, 7); // same ISO week
    final nextMonday = DateTime.utc(2026, 1, 12); // 2026-W03

    final mondayResult = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: monday, progressValue: 1),
    );
    final mondayXp =
        (mondayResult as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(mondayXp, 100); // 80 * 1.25

    // Wednesday, same ISO week: progress reads back as the SAME occurrence
    // row (keyed by Monday's anchor), already complete from Monday's
    // completion.
    final progressMidWeek = await progressRepository.getForQuestAndDate(
      'q1',
      monday, // the occurrence anchor every same-week read/write resolves to
    );
    expect(progressMidWeek!.isComplete, isTrue);

    final wednesdayResult = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: wednesday, progressValue: 1),
    );
    final wednesdayXp =
        (wednesdayResult as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(wednesdayXp, 40); // diminished — same occurrence as Monday's

    final entriesAfterWeek1 = await ledgerRepository.getTransactionsForQuest(
      'q1',
    );
    expect(entriesAfterWeek1.map((t) => t.sourceId).toSet().length, 2);

    // The following Monday: a fresh ISO week. Progress for that week's
    // anchor doesn't exist yet — reset by construction.
    final progressBeforeWeek2 = await progressRepository.getForQuestAndDate(
      'q1',
      nextMonday,
    );
    expect(progressBeforeWeek2, isNull);

    final nextWeekResult = await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: nextMonday, progressValue: 1),
    );
    final nextWeekXp =
        (nextWeekResult as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(
      nextWeekXp,
      greaterThan(wednesdayXp),
    ); // fresh occurrence, not diminished

    expect(
      await ledgerRepository.sumLifetimeXp(),
      mondayXp + wednesdayXp + nextWeekXp,
    );
    final allEntries = await ledgerRepository.getTransactionsForQuest('q1');
    expect(allEntries.map((t) => t.sourceId).toSet().length, 3);
  });

  test('persistence: restart mid-ISO-week preserves the ledger and keeps '
      'reading the same occurrence row; restart after the week rolls over '
      'reads fresh (reset) progress', () async {
    await HiveQuestRepository(
      await openQuestBox(),
    ).upsert(buildQuest(Repeatability.weekly));
    final useCase = await buildUseCase();

    final monday = DateTime.utc(2026, 1, 5);
    await useCase.execute(
      CompleteQuestCommand(questId: 'q1', date: monday, progressValue: 1),
    );

    // Simulate an app restart still within the same ISO week.
    await support.reopen();
    final progressAfterRestart = await HiveQuestProgressRepository(
      await openProgressBox(),
    ).getForQuestAndDate('q1', monday);
    expect(progressAfterRestart!.isComplete, isTrue); // preserved, same week
    final ledgerAfterRestart = HiveXpLedgerRepository(await openLedgerBox());
    expect(await ledgerAfterRestart.sumLifetimeXp(), 100); // preserved

    // Simulate a second restart, this time after the ISO week has rolled
    // over — reading under the NEW week's anchor finds nothing (reset),
    // while the ledger from the first week is still intact.
    await support.reopen();
    final nextMonday = DateTime.utc(2026, 1, 12);
    final progressNewWeek = await HiveQuestProgressRepository(
      await openProgressBox(),
    ).getForQuestAndDate('q1', nextMonday);
    expect(progressNewWeek, isNull); // reset
    final ledgerStillIntact = HiveXpLedgerRepository(await openLedgerBox());
    expect(await ledgerStillIntact.sumLifetimeXp(), 100); // never erased
  });
}
