import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../../../../support/hive_test_support.dart';

Quest _buildQuest({
  String id = 'q1',
  String title = 'Workout',
  QuestCompletionState state = QuestCompletionState.notStarted,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
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

  Future<Box<QuestHiveModel>> openBox() =>
      Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);

  test('upsert then getById returns the same quest', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    final quest = _buildQuest();

    await repo.upsert(quest);
    final fetched = await repo.getById(quest.id);

    expect(fetched, quest);
  });

  test('getById returns null for an unknown id', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);

    expect(await repo.getById('missing'), isNull);
  });

  test('repeated upsert replaces the same quest, not duplicates it', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    final quest = _buildQuest();

    await repo.upsert(quest);
    await repo.upsert(quest.copyWith(state: QuestCompletionState.complete));

    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.single.state, QuestCompletionState.complete);
  });

  test(
    'getAll returns every stored quest, deterministically ordered',
    () async {
      final box = await openBox();
      final repo = HiveQuestRepository(box);

      await repo.upsert(_buildQuest(id: 'z-quest'));
      await repo.upsert(_buildQuest(id: 'a-quest'));
      await repo.upsert(_buildQuest(id: 'm-quest'));

      final all = await repo.getAll();
      expect(all.map((q) => q.id).toList(), ['a-quest', 'm-quest', 'z-quest']);
    },
  );

  test('watchAll emits the current snapshot immediately', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    await repo.upsert(_buildQuest());

    final first = await repo.watchAll().first;
    expect(first.map((q) => q.id), ['q1']);
  });

  test('watchAll emits again after a subsequent change', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);

    final emissions = <List<Quest>>[];
    final subscription = repo.watchAll().listen(emissions.add);
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    expect(emissions, hasLength(1));
    expect(emissions.first, isEmpty);

    await repo.upsert(_buildQuest());
    await pumpEventQueue();

    expect(emissions.length, greaterThanOrEqualTo(2));
    expect(emissions.last.map((q) => q.id), ['q1']);
  });

  test('deleteById removes the quest record', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    await repo.upsert(_buildQuest());

    await repo.deleteById('q1');

    expect(await repo.getById('q1'), isNull);
    expect(await repo.getAll(), isEmpty);
  });

  test('deleteById on an unknown id is a no-op', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    await repo.upsert(_buildQuest());

    await repo.deleteById('missing');

    expect(await repo.getAll(), hasLength(1));
  });

  test('watchAll emits again after a deleteById', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    await repo.upsert(_buildQuest());

    final emissions = <List<Quest>>[];
    final subscription = repo.watchAll().listen(emissions.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();
    expect(emissions.single, hasLength(1));

    await repo.deleteById('q1');
    await pumpEventQueue();

    expect(emissions.last, isEmpty);
  });

  test('persistence survives closing and reopening the box', () async {
    final box = await openBox();
    final repo = HiveQuestRepository(box);
    await repo.upsert(_buildQuest(state: QuestCompletionState.inProgress));

    await support.reopen();
    final reopenedBox = await openBox();
    final reopenedRepo = HiveQuestRepository(reopenedBox);

    final fetched = await reopenedRepo.getById('q1');
    expect(fetched, isNotNull);
    expect(fetched!.state, QuestCompletionState.inProgress);
  });
}
