import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';

import '../../../../support/hive_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<Box<QuestProgressHiveModel>> openBox() =>
      Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);

  test(
    'upsert then read by normalized date returns the same progress',
    () async {
      final box = await openBox();
      final repo = HiveQuestProgressRepository(box);
      final progress = QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      );

      await repo.upsert(progress);
      final fetched = await repo.getForQuestAndDate(
        'q1',
        DateTime.utc(2026, 1, 10),
      );

      expect(fetched, progress);
    },
  );

  test(
    'a query date with a time-of-day component still matches the normalized row',
    () async {
      final box = await openBox();
      final repo = HiveQuestProgressRepository(box);
      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
          isComplete: true,
        ),
      );

      final fetched = await repo.getForQuestAndDate(
        'q1',
        DateTime.utc(2026, 1, 10, 23, 59, 59),
      );
      expect(fetched, isNotNull);
    },
  );

  test(
    'a second upsert for the same quest/date replaces the row, not duplicates it',
    () async {
      final box = await openBox();
      final repo = HiveQuestProgressRepository(box);
      final date = DateTime.utc(2026, 1, 10);

      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: date,
          progressValue: 0.5,
          isComplete: false,
        ),
      );
      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: date,
          progressValue: 1,
          isComplete: true,
        ),
      );

      final all = await repo.getForQuest('q1');
      expect(all.length, 1);
      expect(all.single.isComplete, isTrue);
      expect(all.single.progressValue, 1);
    },
  );

  test('different dates for the same quest remain separate rows', () async {
    final box = await openBox();
    final repo = HiveQuestProgressRepository(box);

    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
    );
    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 11),
        progressValue: 1,
        isComplete: true,
      ),
    );

    final all = await repo.getForQuest('q1');
    expect(all.length, 2);
  });

  test('different quests on the same date remain separate rows', () async {
    final box = await openBox();
    final repo = HiveQuestProgressRepository(box);
    final date = DateTime.utc(2026, 1, 10);

    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: date,
        progressValue: 1,
        isComplete: true,
      ),
    );
    await repo.upsert(
      QuestProgress(
        questId: 'q2',
        date: date,
        progressValue: 1,
        isComplete: true,
      ),
    );

    expect(await repo.getForQuestAndDate('q1', date), isNotNull);
    expect(await repo.getForQuestAndDate('q2', date), isNotNull);
    expect((await repo.getForQuest('q1')).length, 1);
    expect((await repo.getForQuest('q2')).length, 1);
  });

  test(
    'getForQuest returns rows in deterministic (date-ascending) order',
    () async {
      final box = await openBox();
      final repo = HiveQuestProgressRepository(box);

      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 15),
          progressValue: 1,
          isComplete: true,
        ),
      );
      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 10),
          progressValue: 1,
          isComplete: true,
        ),
      );
      await repo.upsert(
        QuestProgress(
          questId: 'q1',
          date: DateTime.utc(2026, 1, 12),
          progressValue: 1,
          isComplete: true,
        ),
      );

      final all = await repo.getForQuest('q1');
      expect(all.map((p) => p.date).toList(), [
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 12),
        DateTime.utc(2026, 1, 15),
      ]);
    },
  );

  test('deleteAllForQuest removes every row for that quest, across dates, '
      'and leaves other quests\' rows untouched', () async {
    final box = await openBox();
    final repo = HiveQuestProgressRepository(box);

    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
    );
    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 11),
        progressValue: 1,
        isComplete: true,
      ),
    );
    await repo.upsert(
      QuestProgress(
        questId: 'q2',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
    );

    await repo.deleteAllForQuest('q1');

    expect(await repo.getForQuest('q1'), isEmpty);
    expect(await repo.getForQuest('q2'), hasLength(1));
  });

  test('deleteAllForQuest for a quest with no rows is a no-op', () async {
    final box = await openBox();
    final repo = HiveQuestProgressRepository(box);
    await repo.upsert(
      QuestProgress(
        questId: 'q2',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
    );

    await repo.deleteAllForQuest('q1'); // never had any rows

    expect(await repo.getForQuest('q2'), hasLength(1));
  });

  test('persistence survives closing and reopening the box', () async {
    final box = await openBox();
    final repo = HiveQuestProgressRepository(box);
    await repo.upsert(
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
        notes: 'good day',
      ),
    );

    await support.reopen();
    final reopenedBox = await openBox();
    final reopenedRepo = HiveQuestProgressRepository(reopenedBox);

    final fetched = await reopenedRepo.getForQuestAndDate(
      'q1',
      DateTime.utc(2026, 1, 10),
    );
    expect(fetched, isNotNull);
    expect(fetched!.notes, 'good day');
  });
}
