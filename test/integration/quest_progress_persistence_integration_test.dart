import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/models/update_quest_progress_command.dart';
import 'package:prime/features/quests/application/models/update_quest_progress_result.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/update_quest_progress_use_case.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/services/quest_progress_policy.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

Future<Box<QuestHiveModel>> _openQuestBox() =>
    Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
Future<Box<QuestProgressHiveModel>> _openProgressBox() =>
    Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
Future<Box<XpTransactionHiveModel>> _openLedgerBox() =>
    Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

Quest _buildQuantityQuest() {
  return const Quest(
    id: 'q1',
    title: 'Drink water',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 40},
    linkedIdentityStatementIds: [],
    progressType: ProgressType.quantity,
    currentProgress: 0,
    targetProgress: 8,
    prerequisiteQuestIds: [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void main() {
  late HiveTestSupport support;
  final today = DateTime.utc(2026, 1, 10);

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<UpdateQuestProgressUseCase> buildUseCase() async {
    final questRepository = HiveQuestRepository(await _openQuestBox());
    final progressRepository = HiveQuestProgressRepository(
      await _openProgressBox(),
    );
    final ledgerRepository = HiveXpLedgerRepository(await _openLedgerBox());
    return UpdateQuestProgressUseCase(
      questRepository: questRepository,
      questProgressRepository: progressRepository,
      completeQuestUseCase: CompleteQuestUseCase(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: ledgerRepository,
        occurrenceService: QuestOccurrenceService(
          xpLedgerRepository: ledgerRepository,
        ),
      ),
    );
  }

  test('progress survives closing and reopening the boxes', () async {
    await HiveQuestRepository(
      await _openQuestBox(),
    ).upsert(_buildQuantityQuest());
    final useCase = await buildUseCase();

    await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 3,
      ),
    );

    await support.reopen();
    final reopenedProgress = HiveQuestProgressRepository(
      await _openProgressBox(),
    );
    final stored = await reopenedProgress.getForQuestAndDate('q1', today);
    expect(stored!.progressValue, 3);
    expect(stored.isComplete, isFalse);
  });

  test(
    'watchAll on the progress box (indirectly, via re-read) reflects every mutation',
    () async {
      await HiveQuestRepository(
        await _openQuestBox(),
      ).upsert(_buildQuantityQuest());
      final progressRepository = HiveQuestProgressRepository(
        await _openProgressBox(),
      );
      final useCase = await buildUseCase();

      final emissions = <double>[];
      // HiveQuestProgressRepository has no watchAll of its own (the box is
      // read by key/questId, not scanned) — this asserts on repeated
      // getForQuestAndDate reads instead, the same access pattern
      // questProgressForDateProvider's invalidate-then-refetch cycle uses.
      for (final amount in [1, 1, 1]) {
        await useCase.execute(
          UpdateQuestProgressCommand(
            questId: 'q1',
            date: today,
            operation: QuestProgressOperation.increment,
            amount: amount.toDouble(),
          ),
        );
        final progress = await progressRepository.getForQuestAndDate(
          'q1',
          today,
        );
        emissions.add(progress!.progressValue);
      }

      expect(emissions, [1, 2, 3]);
    },
  );

  test('reaching the target persists completion and the XP ledger contains '
      'exactly one completion transaction', () async {
    await HiveQuestRepository(
      await _openQuestBox(),
    ).upsert(_buildQuantityQuest());
    final useCase = await buildUseCase();

    final result = await useCase.execute(
      UpdateQuestProgressCommand(
        questId: 'q1',
        date: today,
        operation: QuestProgressOperation.increment,
        amount: 8,
      ),
    );
    expect(result, isA<Ok<UpdateQuestProgressResult>>());

    final progressRepository = HiveQuestProgressRepository(
      await _openProgressBox(),
    );
    final stored = await progressRepository.getForQuestAndDate('q1', today);
    expect(stored!.isComplete, isTrue);

    final ledgerRepository = HiveXpLedgerRepository(await _openLedgerBox());
    final transactions = await ledgerRepository.getTransactionsForQuestAndDate(
      'q1',
      today,
    );
    expect(transactions.length, 1); // one attribute weight -> one row
    expect(await ledgerRepository.sumLifetimeXp(), greaterThan(0));
  });

  test(
    'decrementing after completion does not remove XP history, and survives a restart',
    () async {
      await HiveQuestRepository(
        await _openQuestBox(),
      ).upsert(_buildQuantityQuest());
      final useCase = await buildUseCase();

      await useCase.execute(
        UpdateQuestProgressCommand(
          questId: 'q1',
          date: today,
          operation: QuestProgressOperation.increment,
          amount: 8,
        ),
      );
      final ledgerBeforeDecrement = HiveXpLedgerRepository(
        await _openLedgerBox(),
      );
      final xpBeforeDecrement = await ledgerBeforeDecrement.sumLifetimeXp();
      expect(xpBeforeDecrement, greaterThan(0));

      await useCase.execute(
        UpdateQuestProgressCommand(
          questId: 'q1',
          date: today,
          operation: QuestProgressOperation.decrement,
          amount: 5,
        ),
      );

      final progressRepository = HiveQuestProgressRepository(
        await _openProgressBox(),
      );
      final stored = await progressRepository.getForQuestAndDate('q1', today);
      expect(stored!.progressValue, 3);
      expect(stored.isComplete, isFalse);

      final ledgerAfterDecrement = HiveXpLedgerRepository(
        await _openLedgerBox(),
      );
      expect(
        await ledgerAfterDecrement.sumLifetimeXp(),
        xpBeforeDecrement,
      ); // unchanged

      await support.reopen();
      final ledgerAfterRestart = HiveXpLedgerRepository(await _openLedgerBox());
      final progressAfterRestart = HiveQuestProgressRepository(
        await _openProgressBox(),
      );
      expect(await ledgerAfterRestart.sumLifetimeXp(), xpBeforeDecrement);
      final storedAfterRestart = await progressAfterRestart.getForQuestAndDate(
        'q1',
        today,
      );
      expect(storedAfterRestart!.progressValue, 3);
      expect(storedAfterRestart.isComplete, isFalse);
    },
  );
}
