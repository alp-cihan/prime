import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/chains/application/services/chain_evaluation_service.dart';
import 'package:prime/features/chains/application/use_cases/evaluate_and_advance_chains_use_case.dart';
import 'package:prime/features/chains/data/models/chain_progress_hive_model.dart';
import 'package:prime/features/chains/data/repositories/hive_chain_progress_repository.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
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

/// End-to-end: define a chain (test-authored, since the built-in catalog is
/// empty by design), complete its quests in order through the real
/// quest-completion pipeline, verify stages unlock one at a time, verify
/// the chain completes and grants its reward exactly once, restart the app
/// (fresh Hive boxes against the same directory), and verify everything
/// survived.
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
  Future<Box<ChainProgressHiveModel>> openChainBox() =>
      Hive.openBox<ChainProgressHiveModel>(HiveBoxNames.chainProgress);

  const chain = Chain(
    id: 'ai_engineer',
    title: 'Become a Professional AI Engineer',
    description: 'A three-step story chain.',
    iconKey: 'book',
    questIds: ['coursework', 'portfolio', 'internship'],
    rewardXp: 200,
    sortOrder: 0,
  );

  Quest buildQuest(String id, String title) {
    return Quest(
      id: id,
      title: title,
      description: '',
      type: QuestType.daily,
      difficulty: QuestDifficulty.normal,
      attributeXpWeights: const {AttributeType.knowledge: 60},
      linkedIdentityStatementIds: const [],
      progressType: ProgressType.binary,
      currentProgress: 0,
      targetProgress: 1,
      prerequisiteQuestIds: const [],
      state: QuestCompletionState.notStarted,
      failureBehavior: FailureBehavior.expire,
    );
  }

  Future<CompleteQuestUseCase> buildCompleteQuestUseCase() async {
    final ledger = HiveXpLedgerRepository(await openLedgerBox());
    return CompleteQuestUseCase(
      questRepository: HiveQuestRepository(await openQuestBox()),
      questProgressRepository: HiveQuestProgressRepository(
        await openProgressBox(),
      ),
      xpLedgerRepository: ledger,
      occurrenceService: QuestOccurrenceService(xpLedgerRepository: ledger),
    );
  }

  Future<EvaluateAndAdvanceChainsUseCase> buildChainUseCase() async {
    final ledger = HiveXpLedgerRepository(await openLedgerBox());
    final chainProgress = HiveChainProgressRepository(await openChainBox());
    return EvaluateAndAdvanceChainsUseCase(
      evaluationService: ChainEvaluationService(
        xpLedgerRepository: ledger,
        progressRepository: chainProgress,
      ),
      progressRepository: chainProgress,
      xpLedgerRepository: ledger,
      catalog: const [chain],
    );
  }

  test('create chain -> complete quests -> unlock stages -> complete chain -> '
      'restart -> verify persistence', () async {
    final questRepository = HiveQuestRepository(await openQuestBox());
    await questRepository.upsert(buildQuest('coursework', 'Core coursework'));
    await questRepository.upsert(
      buildQuest('portfolio', 'Three portfolio projects'),
    );
    await questRepository.upsert(buildQuest('internship', 'Internship'));

    final completeQuest = await buildCompleteQuestUseCase();
    final chainProgressRepo = HiveChainProgressRepository(await openChainBox());

    // Stage 1: complete the first quest, then evaluate.
    final r1 = await completeQuest.execute(
      CompleteQuestCommand(
        questId: 'coursework',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      ),
    );
    expect(r1, isA<Ok<CompleteQuestResult>>());
    var chainUseCase = await buildChainUseCase();
    var evaluated = await chainUseCase.execute();
    expect((evaluated as Ok<List<Chain>>).value, isEmpty); // not finished yet

    var progress = await chainProgressRepo.getForChain('ai_engineer');
    expect(progress!.completedStageCount, 1);
    expect(progress.completedAt, isNull);

    // Stage 2.
    await completeQuest.execute(
      CompleteQuestCommand(
        questId: 'portfolio',
        date: DateTime.utc(2026, 1, 11),
        progressValue: 1,
      ),
    );
    chainUseCase = await buildChainUseCase();
    await chainUseCase.execute();
    progress = await chainProgressRepo.getForChain('ai_engineer');
    expect(progress!.completedStageCount, 2);
    expect(progress.completedAt, isNull);

    // Stage 3 — the final stage: completing it must finish the chain and
    // grant its reward exactly once.
    await completeQuest.execute(
      CompleteQuestCommand(
        questId: 'internship',
        date: DateTime.utc(2026, 1, 12),
        progressValue: 1,
      ),
    );
    chainUseCase = await buildChainUseCase();
    evaluated = await chainUseCase.execute();
    expect((evaluated as Ok<List<Chain>>).value.map((c) => c.id), [
      'ai_engineer',
    ]);

    final ledgerBeforeRestart = HiveXpLedgerRepository(await openLedgerBox());
    final totalBeforeRestart = await ledgerBeforeRestart.sumLifetimeXp();
    progress = await chainProgressRepo.getForChain('ai_engineer');
    expect(progress!.completedStageCount, 3);
    expect(progress.completedAt, isNotNull);

    // Re-evaluating an already-completed chain must not re-grant the
    // reward or re-touch progress.
    chainUseCase = await buildChainUseCase();
    final reEvaluated = await chainUseCase.execute();
    expect((reEvaluated as Ok<List<Chain>>).value, isEmpty);
    expect(await ledgerBeforeRestart.sumLifetimeXp(), totalBeforeRestart);

    // Simulate an app restart.
    await support.reopen();

    final ledgerAfterRestart = HiveXpLedgerRepository(await openLedgerBox());
    final chainProgressAfterRestart = HiveChainProgressRepository(
      await openChainBox(),
    );
    final progressAfterRestart = await chainProgressAfterRestart.getForChain(
      'ai_engineer',
    );
    expect(progressAfterRestart!.completedStageCount, 3);
    expect(progressAfterRestart.completedAt, isNotNull);
    expect(
      await ledgerAfterRestart.sumLifetimeXp(),
      totalBeforeRestart,
    ); // preserved exactly, no duplicate reward after restart

    // A post-restart evaluation pass must still be a no-op.
    final useCaseAfterRestart = EvaluateAndAdvanceChainsUseCase(
      evaluationService: ChainEvaluationService(
        xpLedgerRepository: ledgerAfterRestart,
        progressRepository: chainProgressAfterRestart,
      ),
      progressRepository: chainProgressAfterRestart,
      xpLedgerRepository: ledgerAfterRestart,
      catalog: const [chain],
    );
    final finalEvaluation = await useCaseAfterRestart.execute();
    expect((finalEvaluation as Ok<List<Chain>>).value, isEmpty);
    expect(await ledgerAfterRestart.sumLifetimeXp(), totalBeforeRestart);
  });
}
