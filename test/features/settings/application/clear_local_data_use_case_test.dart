import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/achievements/data/models/achievement_unlock_hive_model.dart';
import 'package:prime/features/chains/data/models/chain_progress_hive_model.dart';
import 'package:prime/features/onboarding/data/repositories/hive_onboarding_repository.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/settings/application/use_cases/clear_local_data_use_case.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';

import '../../../support/hive_test_support.dart';

QuestHiveModel _quest() => QuestHiveModel(
  id: 'q1',
  title: 'Workout',
  description: 'desc',
  type: 'daily',
  difficulty: 'normal',
  attributeXpWeights: const {'health': 60},
  linkedIdentityStatementIds: const [],
  progressType: 'binary',
  currentProgress: 0,
  targetProgress: 1,
  prerequisiteQuestIds: const [],
  state: 'notStarted',
  failureBehavior: 'expire',
);

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('deletes every Prime-owned box and reopens them all empty', () async {
    // Populate one row in every box Prime owns.
    final questBox = await Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
    await questBox.put('q1', _quest());

    final progressBox = await Hive.openBox<QuestProgressHiveModel>(
      HiveBoxNames.questProgress,
    );
    await progressBox.put(
      'q1|2026-01-10',
      QuestProgressHiveModel(
        questId: 'q1',
        dateUtcMicros: DateTime.utc(2026, 1, 10).microsecondsSinceEpoch,
        progressValue: 1,
        isComplete: true,
      ),
    );

    final ledgerBox = await Hive.openBox<XpTransactionHiveModel>(
      HiveBoxNames.xpTransactions,
    );
    await ledgerBox.put(
      'tx1',
      XpTransactionHiveModel(
        id: 'tx1',
        sourceType: 'quest',
        sourceId: 'q1|2026-01-10|0',
        attribute: 'health',
        baseXp: 60,
        modifiersApplied: const {},
        finalXp: 75,
        createdAtUtcMicros: DateTime.utc(2026, 1, 10).microsecondsSinceEpoch,
        idempotencyKey: 'q1|health|2026-01-10|0',
      ),
    );

    final achievementBox = await Hive.openBox<AchievementUnlockHiveModel>(
      HiveBoxNames.achievementUnlocks,
    );
    await achievementBox.put(
      'first_step',
      AchievementUnlockHiveModel(
        achievementId: 'first_step',
        unlockedAtUtcMicros: DateTime.utc(2026, 1, 10).microsecondsSinceEpoch,
      ),
    );

    final chainBox = await Hive.openBox<ChainProgressHiveModel>(
      HiveBoxNames.chainProgress,
    );
    await chainBox.put(
      'chain1',
      ChainProgressHiveModel(
        chainId: 'chain1',
        completedStageCount: 1,
        completedAtUtcMicros: null,
      ),
    );

    final preferencesBox = await Hive.openBox<bool>(
      HiveBoxNames.appPreferences,
    );
    HiveOnboardingRepository(preferencesBox).markCompleted();

    expect(questBox.isNotEmpty, isTrue);
    expect(progressBox.isNotEmpty, isTrue);
    expect(ledgerBox.isNotEmpty, isTrue);
    expect(achievementBox.isNotEmpty, isTrue);
    expect(chainBox.isNotEmpty, isTrue);
    expect(preferencesBox.isNotEmpty, isTrue);

    await const ClearLocalDataUseCase().execute();

    // Every box is reopened, empty, under the same names.
    for (final name in HiveBoxNames.all) {
      expect(Hive.isBoxOpen(name), isTrue, reason: '$name should reopen');
    }
    expect(Hive.box<QuestHiveModel>(HiveBoxNames.quests).isEmpty, isTrue);
    expect(
      Hive.box<QuestProgressHiveModel>(HiveBoxNames.questProgress).isEmpty,
      isTrue,
    );
    expect(
      Hive.box<XpTransactionHiveModel>(HiveBoxNames.xpTransactions).isEmpty,
      isTrue,
    );
    expect(
      Hive.box<AchievementUnlockHiveModel>(
        HiveBoxNames.achievementUnlocks,
      ).isEmpty,
      isTrue,
    );
    expect(
      Hive.box<ChainProgressHiveModel>(HiveBoxNames.chainProgress).isEmpty,
      isTrue,
    );
    final freshPreferences = Hive.box<bool>(HiveBoxNames.appPreferences);
    expect(
      HiveOnboardingRepository(freshPreferences).isCompleted(),
      isFalse,
      reason: 'clearing data returns onboarding to first-run state too',
    );
  });

  test('is safe to call on already-empty boxes', () async {
    await Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
    await Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
    await Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);
    await Hive.openBox<AchievementUnlockHiveModel>(
      HiveBoxNames.achievementUnlocks,
    );
    await Hive.openBox<ChainProgressHiveModel>(HiveBoxNames.chainProgress);
    await Hive.openBox<bool>(HiveBoxNames.appPreferences);

    await const ClearLocalDataUseCase().execute();

    for (final name in HiveBoxNames.all) {
      expect(Hive.isBoxOpen(name), isTrue);
    }
  });
}
