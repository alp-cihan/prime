import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/achievements/application/services/achievement_evaluation_service.dart';
import 'package:prime/features/achievements/application/use_cases/evaluate_and_unlock_achievements_use_case.dart';
import 'package:prime/features/achievements/data/models/achievement_unlock_hive_model.dart';
import 'package:prime/features/achievements/data/repositories/hive_achievement_unlock_repository.dart';
import 'package:prime/features/achievements/domain/catalog/achievement_catalog.dart';
import 'package:prime/features/chains/application/services/chain_evaluation_service.dart';
import 'package:prime/features/chains/application/use_cases/evaluate_and_advance_chains_use_case.dart';
import 'package:prime/features/chains/data/models/chain_progress_hive_model.dart';
import 'package:prime/features/chains/data/repositories/hive_chain_progress_repository.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/identity/application/services/identity_service.dart';
import 'package:prime/features/identity/domain/entities/identity_milestone.dart';
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

import '../support/fake_repositories.dart';
import '../support/hive_test_support.dart';

/// End-to-end: complete a quest through the real completion pipeline, unlock
/// an achievement, complete a (test-authored) chain, then verify
/// `IdentityService` derives a snapshot/timeline consistent with all three —
/// entirely from those features' own repositories, with no persistence of
/// its own. Also verifies restart consistency: rebuilding the service
/// against reopened Hive boxes must reproduce identical results.
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
  Future<Box<ChainProgressHiveModel>> openChainBox() =>
      Hive.openBox<ChainProgressHiveModel>(HiveBoxNames.chainProgress);

  const chain = Chain(
    id: 'morning_routine',
    title: 'Morning Routine',
    description: 'A one-step chain.',
    iconKey: 'sunrise',
    questIds: ['q1'],
    rewardXp: 50,
    sortOrder: 0,
  );

  Quest buildQuest() {
    return const Quest(
      id: 'q1',
      title: 'Workout',
      description: 'Go to the gym',
      type: QuestType.daily,
      difficulty: QuestDifficulty.normal,
      attributeXpWeights: {AttributeType.health: 100},
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
  Future<HiveChainProgressRepository> chainProgressRepo() async =>
      HiveChainProgressRepository(await openChainBox());

  Future<IdentityService> buildIdentityService() async {
    return IdentityService(
      xpLedgerRepository: await ledgerRepo(),
      achievementUnlockRepository: await unlockRepo(),
      chainProgressRepository: await chainProgressRepo(),
      achievements: achievementCatalog,
      chains: const [chain],
    );
  }

  test(
    'complete quest -> unlock achievement -> complete chain -> identity '
    'snapshot and timeline are consistent -> restart -> identical results',
    () async {
      await HiveQuestRepository(await openQuestBox()).upsert(buildQuest());
      final ledger = await ledgerRepo();

      // 1. Complete the quest — 2026-01-10.
      final completeQuest = CompleteQuestUseCase(
        questRepository: HiveQuestRepository(await openQuestBox()),
        questProgressRepository: HiveQuestProgressRepository(
          await openProgressBox(),
        ),
        xpLedgerRepository: ledger,
        occurrenceService: QuestOccurrenceService(xpLedgerRepository: ledger),
        clock: FakeClock(DateTime.utc(2026, 1, 10)),
      );
      final completion = await completeQuest.execute(
        CompleteQuestCommand(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
        ),
      );
      expect(completion, isA<Ok<CompleteQuestResult>>());
      final questXp =
          (completion as Ok<CompleteQuestResult>).value.totalXpAwarded;

      // 2. Unlock achievements — 2026-01-11 ("First Step": 1 completion).
      final evaluateAchievements = EvaluateAndUnlockAchievementsUseCase(
        evaluationService: AchievementEvaluationService(
          xpLedgerRepository: ledger,
          unlockRepository: await unlockRepo(),
        ),
        unlockRepository: await unlockRepo(),
        xpLedgerRepository: ledger,
        clock: FakeClock(DateTime.utc(2026, 1, 11)),
      );
      final unlocked = await evaluateAchievements.execute();
      expect((unlocked as Ok).value.map((a) => a.id), ['first_step']);

      // 3. Complete the chain — 2026-01-12 (its one stage is q1, already done).
      final evaluateChains = EvaluateAndAdvanceChainsUseCase(
        evaluationService: ChainEvaluationService(
          xpLedgerRepository: ledger,
          progressRepository: await chainProgressRepo(),
        ),
        progressRepository: await chainProgressRepo(),
        xpLedgerRepository: ledger,
        catalog: const [chain],
        clock: FakeClock(DateTime.utc(2026, 1, 12)),
      );
      final completedChains = await evaluateChains.execute();
      expect((completedChains as Ok<List<Chain>>).value.map((c) => c.id), [
        'morning_routine',
      ]);

      // 4. Build the identity snapshot/timeline and verify consistency.
      final identityService = await buildIdentityService();
      final snapshot = await identityService.buildSnapshot(
        at: DateTime.utc(2026, 1, 12),
      );
      final totalXp = await ledger.sumLifetimeXp();

      expect(snapshot.completedQuests, 1);
      expect(snapshot.unlockedAchievements, 1);
      expect(snapshot.completedChains, 1);
      expect(snapshot.lifetimeXp, totalXp);
      expect(snapshot.lifetimeXp, greaterThan(questXp)); // reward XP included
      expect(
        snapshot.attributeXp[AttributeType.health],
        greaterThanOrEqualTo(questXp),
      );
      expect(snapshot.firstQuestDate, DateTime.utc(2026, 1, 10));
      expect(snapshot.latestActivityDate, DateTime.utc(2026, 1, 12));

      final milestones = await identityService.recentMilestones();
      // Newest first: chain completion, then achievement unlock, then
      // (possibly) a level-reached milestone from the initial completion.
      expect(milestones.first.type, IdentityMilestoneType.chainCompleted);
      expect(milestones.first.title, 'Completed "Morning Routine"');
      final achievementMilestone = milestones.firstWhere(
        (m) => m.type == IdentityMilestoneType.achievementUnlocked,
      );
      expect(achievementMilestone.title, 'Unlocked "First Step"');

      // 5. Simulate an app restart — rebuild everything against reopened
      // boxes and verify identical results (CLAUDE.md: cached totals are
      // projections; a restart must reproduce the same derived numbers).
      await support.reopen();

      final identityServiceAfterRestart = await buildIdentityService();
      final snapshotAfterRestart = await identityServiceAfterRestart
          .buildSnapshot(at: DateTime.utc(2026, 1, 12));
      final milestonesAfterRestart = await identityServiceAfterRestart
          .recentMilestones();

      expect(snapshotAfterRestart, snapshot);
      expect(milestonesAfterRestart, milestones);
    },
  );
}
