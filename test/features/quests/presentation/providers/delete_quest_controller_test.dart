import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/providers/delete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

Quest _buildQuest({String id = 'q1'}) {
  return Quest(
    id: id,
    title: 'Workout',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
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

  test('idle -> loading -> success', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());

    final states = <AsyncValue<bool>>[];
    final subscription = container.listen(
      deleteQuestControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(states.single, const AsyncData<bool>(false)); // idle

    await container.read(deleteQuestControllerProvider.notifier).delete('q1');

    expect(states.any((s) => s.isLoading), isTrue);
    expect(states.last, const AsyncData<bool>(true));
    expect(await container.read(questRepositoryProvider).getById('q1'), isNull);
  });

  test('idle -> loading -> error', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    // No quest seeded: deleting a missing id fails with NotFoundFailure.

    await container
        .read(deleteQuestControllerProvider.notifier)
        .delete('missing');

    final state = container.read(deleteQuestControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NotFoundFailure>());
  });

  test('prevents duplicate deletion while in flight', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());
    final notifier = container.read(deleteQuestControllerProvider.notifier);

    final first = notifier.delete('q1');
    final second = notifier.delete('q1');
    await first;
    await second;

    expect(container.read(deleteQuestControllerProvider).value, isTrue);
  });

  test('retry after failure works', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final notifier = container.read(deleteQuestControllerProvider.notifier);

    await notifier.delete('missing'); // fails
    expect(container.read(deleteQuestControllerProvider).hasError, isTrue);

    await container.read(questRepositoryProvider).upsert(_buildQuest());
    await notifier.delete('q1'); // retry, now valid

    expect(container.read(deleteQuestControllerProvider).value, isTrue);
  });

  test('deletion also removes QuestProgress rows for that quest', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());
    await container
        .read(questProgressRepositoryProvider)
        .upsert(
          QuestProgress(
            questId: 'q1',
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
            isComplete: true,
          ),
        );

    await container.read(deleteQuestControllerProvider.notifier).delete('q1');

    expect(
      await container.read(questProgressRepositoryProvider).getForQuest('q1'),
      isEmpty,
    );
  });

  test('resets cleanly back to idle', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());
    await container.read(deleteQuestControllerProvider.notifier).delete('q1');
    expect(container.read(deleteQuestControllerProvider).value, isTrue);

    container.read(deleteQuestControllerProvider.notifier).reset();

    expect(
      container.read(deleteQuestControllerProvider),
      const AsyncData<bool>(false),
    );
  });
}
