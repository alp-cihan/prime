import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/achievements/application/services/achievement_evaluation_service.dart';
import 'package:prime/features/achievements/application/use_cases/evaluate_and_unlock_achievements_use_case.dart';
import 'package:prime/features/achievements/data/models/achievement_unlock_hive_model.dart';
import 'package:prime/features/achievements/data/repositories/hive_achievement_unlock_repository.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

/// End-to-end: complete a quest through the real quest-completion pipeline,
/// evaluate achievements against the real built-in catalog, restart the
/// app (fresh Hive boxes against the same directory), and verify the
/// unlock survived with no duplicate reward XP.
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
  Future<Box<AchievementUnlockHiveModel>> openAchievementBox() =>
      Hive.openBox<AchievementUnlockHiveModel>(HiveBoxNames.achievementUnlocks);

  Quest buildQuest() {
    return const Quest(
      id: 'q1',
      title: 'Workout',
      description: 'Go to the gym',
      type: QuestType.daily,
      difficulty: QuestDifficulty.normal,
      attributeXpWeights: {
        AttributeType.health: 60,
        AttributeType.strength: 40,
      },
      linkedIdentityStatementIds: [],
      progressType: ProgressType.binary,
      currentProgress: 0,
      targetProgress: 1,
      prerequisiteQuestIds: [],
      state: QuestCompletionState.notStarted,
      failureBehavior: FailureBehavior.expire,
    );
  }

  Future<HiveXpLedgerRepository> ledgerRepo() async =>
      HiveXpLedgerRepository(await openLedgerBox());
  Future<HiveAchievementUnlockRepository> unlockRepo() async =>
      HiveAchievementUnlockRepository(await openAchievementBox());

  Future<EvaluateAndUnlockAchievementsUseCase> buildEvaluationUseCase() async {
    final ledger = await ledgerRepo();
    final unlocks = await unlockRepo();
    return EvaluateAndUnlockAchievementsUseCase(
      evaluationService: AchievementEvaluationService(
        xpLedgerRepository: ledger,
        unlockRepository: unlocks,
      ),
      unlockRepository: unlocks,
      xpLedgerRepository: ledger,
    );
  }

  test(
    'complete quest -> unlock achievement -> restart -> still unlocked, no duplicate XP',
    () async {
      await HiveQuestRepository(await openQuestBox()).upsert(buildQuest());
      final ledger = await ledgerRepo();
      final completeUseCase = CompleteQuestUseCase(
        questRepository: HiveQuestRepository(await openQuestBox()),
        questProgressRepository: HiveQuestProgressRepository(
          await openProgressBox(),
        ),
        xpLedgerRepository: ledger,
        occurrenceService: QuestOccurrenceService(xpLedgerRepository: ledger),
      );

      final completion = await completeUseCase.execute(
        CompleteQuestCommand(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
        ),
      );
      expect(completion, isA<Ok<CompleteQuestResult>>());
      final questXp =
          (completion as Ok<CompleteQuestResult>).value.totalXpAwarded;

      // Evaluate: the built-in catalog's "First Step" (1 quest completion)
      // must unlock; nothing that needs 5 completions, level 5, etc. should.
      final evaluationUseCase = await buildEvaluationUseCase();
      final evaluated = await evaluationUseCase.execute();
      final unlocked = (evaluated as Ok).value as List;
      expect(unlocked.map((a) => a.id), ['first_step']);

      final totalAfterUnlock = await ledger.sumLifetimeXp();
      expect(totalAfterUnlock, greaterThan(questXp)); // reward XP was added

      final unlockRecord = (await unlockRepo()).getAll();
      final firstStepUnlock = (await unlockRecord).single;
      expect(firstStepUnlock.achievementId, 'first_step');

      // Simulate an app restart.
      await support.reopen();

      final ledgerAfterRestart = await ledgerRepo();
      final unlocksAfterRestart = await unlockRepo();
      expect(await unlocksAfterRestart.isUnlocked('first_step'), isTrue);
      final totalAfterRestart = await ledgerAfterRestart.sumLifetimeXp();
      expect(totalAfterRestart, totalAfterUnlock); // preserved exactly

      // Re-evaluating after restart must not unlock it again or grant its
      // reward XP a second time.
      final evaluationUseCaseAfterRestart = await buildEvaluationUseCase();
      final reEvaluated = await evaluationUseCaseAfterRestart.execute();
      expect((reEvaluated as Ok).value, isEmpty);
      expect(await ledgerAfterRestart.sumLifetimeXp(), totalAfterUnlock);

      final unlocksList = await unlocksAfterRestart.getAll();
      expect(
        unlocksList.where((u) => u.achievementId == 'first_step').length,
        1,
      );
    },
  );
}
