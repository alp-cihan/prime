import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/onboarding/application/use_cases/create_starter_quests_use_case.dart';
import 'package:prime/features/onboarding/data/repositories/hive_onboarding_repository.dart';
import 'package:prime/features/onboarding/domain/catalog/starter_quest_template.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/services/quest_occurrence_service.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/create_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

/// Phase 14: "restart persistence after onboarding and quest completion" —
/// a real-Hive (no widget tree), full-lifecycle proof that finishing
/// onboarding (with a selected starter quest) and then completing that quest
/// both survive a simulated app restart, exactly as the equivalent
/// use-case-level tests already prove for quest completion alone (see
/// `complete_quest_persistence_integration_test.dart`) and identity alone
/// (see `identity_full_flow_test.dart`).
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
  Future<Box<bool>> openPreferencesBox() =>
      Hive.openBox<bool>(HiveBoxNames.appPreferences);

  test('onboarding completion + a starter quest + its completion all survive a '
      'restart', () async {
    // 1. Onboarding: select one starter template, finish.
    final questRepository = HiveQuestRepository(await openQuestBox());
    final createStarterQuests = CreateStarterQuestsUseCase(
      questRepository: questRepository,
      createQuestUseCase: CreateQuestUseCase(questRepository: questRepository),
    );
    // A binary template ("Plan tomorrow") — its `CompleteQuestUseCase` call
    // matches the real app's binary completion path exactly (see
    // `_BinaryControls._complete`, which always passes
    // `quest.targetProgress`); the quantity/duration templates are
    // completed incrementally through a different use case instead, not
    // relevant to what this test is verifying.
    final template = starterQuestTemplateCatalog.firstWhere(
      (t) => t.progressType == ProgressType.binary,
    );
    final createResult = await createStarterQuests.execute([template]);
    expect(createResult, isA<Ok<List<dynamic>>>());
    final createdQuestId = (createResult as Ok).value.single.id as String;

    final onboardingRepository = HiveOnboardingRepository(
      await openPreferencesBox(),
    );
    onboardingRepository.markCompleted();

    // 2. Complete the starter quest for real XP.
    final ledger = HiveXpLedgerRepository(await openLedgerBox());
    final completeQuest = CompleteQuestUseCase(
      questRepository: questRepository,
      questProgressRepository: HiveQuestProgressRepository(
        await openProgressBox(),
      ),
      xpLedgerRepository: ledger,
      occurrenceService: QuestOccurrenceService(xpLedgerRepository: ledger),
    );
    final date = DateTime.utc(2026, 1, 10);
    final completion = await completeQuest.execute(
      CompleteQuestCommand(
        questId: createdQuestId,
        date: date,
        progressValue: template.targetProgress,
      ),
    );
    expect(completion, isA<Ok<CompleteQuestResult>>());
    final xpAwarded =
        (completion as Ok<CompleteQuestResult>).value.totalXpAwarded;
    expect(xpAwarded, greaterThan(0));

    // 3. Simulate an app restart.
    await support.reopen();

    final onboardingAfterRestart = HiveOnboardingRepository(
      await openPreferencesBox(),
    );
    expect(onboardingAfterRestart.isCompleted(), isTrue);

    final questAfterRestart = await HiveQuestRepository(
      await openQuestBox(),
    ).getById(createdQuestId);
    expect(questAfterRestart, isNotNull);
    expect(questAfterRestart!.title, template.title);

    final progressAfterRestart = await HiveQuestProgressRepository(
      await openProgressBox(),
    ).getForQuestAndDate(createdQuestId, date);
    expect(progressAfterRestart, isNotNull);
    expect(progressAfterRestart!.isComplete, isTrue);

    final ledgerAfterRestart = HiveXpLedgerRepository(await openLedgerBox());
    expect(await ledgerAfterRestart.sumLifetimeXp(), xpAwarded);
    expect(
      await ledgerAfterRestart.sumXpForAttribute(
        template.attributeXpWeights.keys.first,
      ),
      xpAwarded,
    );
  });
}
