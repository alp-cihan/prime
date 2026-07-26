import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/quests/application/id_generator.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/application/models/create_quest_command.dart';
import 'package:prime/features/quests/application/models/delete_quest_command.dart';
import 'package:prime/features/quests/application/models/update_quest_command.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/create_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/delete_quest_use_case.dart';
import 'package:prime/features/quests/application/use_cases/update_quest_use_case.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';

import '../support/hive_test_support.dart';

class _FixedIdGenerator implements IdGenerator {
  const _FixedIdGenerator(this._id);
  final String _id;
  @override
  String generate() => _id;
}

Future<Box<QuestHiveModel>> _openQuestBox() =>
    Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
Future<Box<QuestProgressHiveModel>> _openProgressBox() =>
    Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
Future<Box<XpTransactionHiveModel>> _openLedgerBox() =>
    Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

CreateQuestCommand _createCommand() {
  return const CreateQuestCommand(
    title: 'Workout',
    description: 'Go to the gym',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 60},
    progressType: ProgressType.binary,
    targetProgress: 1,
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
    'create quest persists through real Hive and reloads after a restart',
    () async {
      final createUseCase = CreateQuestUseCase(
        questRepository: HiveQuestRepository(await _openQuestBox()),
        idGenerator: const _FixedIdGenerator('q1'),
      );

      final result = await createUseCase.execute(_createCommand());
      expect(result, isA<Ok<Quest>>());

      await support.reopen();
      final reopened = HiveQuestRepository(await _openQuestBox());
      final reloaded = await reopened.getById('q1');

      expect(reloaded, isNotNull);
      expect(reloaded!.title, 'Workout');
    },
  );

  test(
    'update quest persists through real Hive and reloads after a restart',
    () async {
      final questRepository = HiveQuestRepository(await _openQuestBox());
      await CreateQuestUseCase(
        questRepository: questRepository,
        idGenerator: const _FixedIdGenerator('q1'),
      ).execute(_createCommand());

      final updateUseCase = UpdateQuestUseCase(
        questRepository: questRepository,
      );
      final updateResult = await updateUseCase.execute(
        const UpdateQuestCommand(
          questId: 'q1',
          title: 'Morning Workout',
          description: 'desc',
          type: QuestType.daily,
          difficulty: QuestDifficulty.hard,
          attributeXpWeights: {AttributeType.health: 80},
          progressType: ProgressType.binary,
          targetProgress: 1,
        ),
      );
      expect(updateResult, isA<Ok<Quest>>());

      await support.reopen();
      final reloaded = await HiveQuestRepository(
        await _openQuestBox(),
      ).getById('q1');

      expect(reloaded!.title, 'Morning Workout');
      expect(reloaded.difficulty, QuestDifficulty.hard);
    },
  );

  test(
    'delete quest removes the Quest record and its QuestProgress rows, '
    'but preserves XpTransaction history — and watchAll reflects every step',
    () async {
      final questRepository = HiveQuestRepository(await _openQuestBox());
      final progressRepository = HiveQuestProgressRepository(
        await _openProgressBox(),
      );
      final ledgerRepository = HiveXpLedgerRepository(await _openLedgerBox());

      final questEmissions = <int>[];
      final subscription = questRepository.watchAll().listen(
        (quests) => questEmissions.add(quests.length),
      );
      addTearDown(subscription.cancel);
      await pumpEventQueue(); // deliver the initial (empty) snapshot first

      // Create.
      await CreateQuestUseCase(
        questRepository: questRepository,
        idGenerator: const _FixedIdGenerator('q1'),
      ).execute(_createCommand());
      await pumpEventQueue();

      // Complete it — produces real QuestProgress + XpTransaction rows.
      final completeUseCase = CompleteQuestUseCase(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
        xpLedgerRepository: ledgerRepository,
      );
      final completion = await completeUseCase.execute(
        CompleteQuestCommand(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
        ),
      );
      expect(completion, isA<Ok<CompleteQuestResult>>());
      final xpBeforeDelete = await ledgerRepository.sumLifetimeXp();
      expect(xpBeforeDelete, greaterThan(0));

      // Update it — still present, still one quest.
      await UpdateQuestUseCase(questRepository: questRepository).execute(
        const UpdateQuestCommand(
          questId: 'q1',
          title: 'Renamed',
          description: 'desc',
          type: QuestType.daily,
          difficulty: QuestDifficulty.normal,
          attributeXpWeights: {AttributeType.health: 60},
          progressType: ProgressType.binary,
          targetProgress: 1,
        ),
      );
      await pumpEventQueue();

      // Delete.
      final deleteUseCase = DeleteQuestUseCase(
        questRepository: questRepository,
        questProgressRepository: progressRepository,
      );
      final deletion = await deleteUseCase.execute(
        const DeleteQuestCommand(questId: 'q1'),
      );
      expect(deletion, isA<Ok<bool>>());
      await pumpEventQueue();

      // Quest record gone.
      expect(await questRepository.getById('q1'), isNull);
      // Progress rows gone.
      expect(await progressRepository.getForQuest('q1'), isEmpty);
      // XP ledger history preserved, untouched by the deletion.
      expect(await ledgerRepository.sumLifetimeXp(), xpBeforeDelete);

      // watchAll reflected every step: 0 (initial) -> 1 (create) -> 1
      // (update, same count) -> 0 (delete).
      expect(questEmissions.first, 0);
      expect(questEmissions.last, 0);
      expect(questEmissions.any((count) => count == 1), isTrue);

      // Survives a restart too.
      await support.reopen();
      expect(
        await HiveQuestRepository(await _openQuestBox()).getById('q1'),
        isNull,
      );
      expect(
        await HiveXpLedgerRepository(await _openLedgerBox()).sumLifetimeXp(),
        xpBeforeDelete,
      );
    },
  );
}
