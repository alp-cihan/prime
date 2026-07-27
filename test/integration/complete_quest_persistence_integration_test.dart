import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

Future<Box<QuestHiveModel>> _openQuestBox() =>
    Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
Future<Box<QuestProgressHiveModel>> _openProgressBox() =>
    Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
Future<Box<XpTransactionHiveModel>> _openLedgerBox() =>
    Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

Quest _buildQuest() {
  return const Quest(
    id: 'q1',
    title: 'Workout',
    description: 'Go to the gym',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 60, AttributeType.strength: 40},
    linkedIdentityStatementIds: [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
    // 'daily' — this test completes the same quest twice on the same day
    // (a genuine second completion, not a raw retry), which only a
    // repeatable quest is allowed to do. See
    // complete_quest_use_case_test.dart's "non-repeatable quest lifetime
    // gating" group for the null-repeatabilityRule, one-time case.
    repeatabilityRule: 'daily',
  );
}

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test(
    'CompleteQuestUseCase persists through real Hive, survives a restart, and a retry does not duplicate XP',
    () async {
      final quest = _buildQuest();
      await HiveQuestRepository(await _openQuestBox()).upsert(quest);

      final useCase = CompleteQuestUseCase(
        questRepository: HiveQuestRepository(await _openQuestBox()),
        questProgressRepository: HiveQuestProgressRepository(
          await _openProgressBox(),
        ),
        xpLedgerRepository: HiveXpLedgerRepository(await _openLedgerBox()),
      );

      final command = CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      );
      final firstResult = await useCase.execute(command);
      expect(firstResult, isA<Ok<CompleteQuestResult>>());
      final firstValue = (firstResult as Ok<CompleteQuestResult>).value;
      expect(
        firstValue.totalXpAwarded,
        125,
      ); // round(100) * 1.25 first-completion bonus

      // Simulate an app restart: close Hive, reopen against the same directory.
      await support.reopen();

      final progressRepoAfterRestart = HiveQuestProgressRepository(
        await _openProgressBox(),
      );
      final ledgerRepoAfterRestart = HiveXpLedgerRepository(
        await _openLedgerBox(),
      );

      final progressAfterRestart = await progressRepoAfterRestart
          .getForQuestAndDate(quest.id, DateTime.utc(2026, 1, 10));
      expect(progressAfterRestart, isNotNull);
      expect(progressAfterRestart!.isComplete, isTrue);

      final transactionsAfterRestart = await ledgerRepoAfterRestart
          .getTransactionsForQuestAndDate(quest.id, DateTime.utc(2026, 1, 10));
      expect(transactionsAfterRestart.length, 2);
      expect(
        transactionsAfterRestart.fold<int>(0, (sum, t) => sum + t.finalXp),
        125,
      );

      // Retry the exact same completion against the restarted repositories.
      final useCaseAfterRestart = CompleteQuestUseCase(
        questRepository: HiveQuestRepository(await _openQuestBox()),
        questProgressRepository: progressRepoAfterRestart,
        xpLedgerRepository: ledgerRepoAfterRestart,
      );
      // A literal retry of the exact same request is simulated by re-appending
      // the already-produced transactions directly through the repository —
      // this is the retry path the architecture's idempotency guarantee
      // covers (see HiveXpLedgerRepository's dedup-by-idempotencyKey).
      await ledgerRepoAfterRestart.appendAll(firstValue.transactions);

      final totalAfterRetry = (await ledgerRepoAfterRestart.getAll()).fold<int>(
        0,
        (sum, t) => sum + t.finalXp,
      );
      expect(totalAfterRetry, 125); // unchanged — the retry was a no-op

      // A genuinely new completion call (not a raw retry) is a distinct
      // action and is correctly treated as a same-day repeat, earning
      // additional (diminished) XP rather than being rejected or duplicated.
      final secondCompletion = await useCaseAfterRestart.execute(command);
      expect(secondCompletion, isA<Ok<CompleteQuestResult>>());
      final secondValue = (secondCompletion as Ok<CompleteQuestResult>).value;
      expect(
        secondValue.totalXpAwarded,
        50,
      ); // diminished repeat, not a duplicate of the first 125

      final finalTotal = await ledgerRepoAfterRestart.sumLifetimeXp();
      expect(finalTotal, 175); // 125 + 50, never 250 or 300
    },
  );
}
