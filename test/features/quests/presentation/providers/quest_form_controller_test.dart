import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/features/quests/application/models/create_quest_command.dart';
import 'package:prime/features/quests/application/models/update_quest_command.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/quest_form_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

CreateQuestCommand _createCommand({String title = 'Workout'}) {
  return CreateQuestCommand(
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
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

  test('create: idle -> loading -> success', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final states = <AsyncValue<Quest?>>[];
    final subscription = container.listen(
      questFormControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(states.single, const AsyncData<Quest?>(null)); // idle

    await container
        .read(questFormControllerProvider.notifier)
        .create(_createCommand());

    expect(states.any((s) => s.isLoading), isTrue);
    expect(states.last.hasValue, isTrue);
    expect(states.last.value?.title, 'Workout');
  });

  test('create: idle -> loading -> error', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    await container
        .read(questFormControllerProvider.notifier)
        .create(_createCommand(title: '   ')); // invalid

    final state = container.read(questFormControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<ValidationFailure>());
  });

  test('create: prevents duplicate submissions while in flight', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final notifier = container.read(questFormControllerProvider.notifier);

    final first = notifier.create(_createCommand());
    final second = notifier.create(_createCommand());
    await first;
    await second;

    final quests = await container.read(questRepositoryProvider).getAll();
    expect(quests.length, 1); // not created twice
  });

  test('create: retry after failure works', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final notifier = container.read(questFormControllerProvider.notifier);

    await notifier.create(_createCommand(title: ''));
    expect(container.read(questFormControllerProvider).hasError, isTrue);

    await notifier.create(_createCommand(title: 'Valid title'));
    expect(container.read(questFormControllerProvider).value, isNotNull);
    expect(
      container.read(questFormControllerProvider).value!.title,
      'Valid title',
    );
  });

  test(
    'update: idle -> loading -> success, exposes the updated quest',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      await container
          .read(questFormControllerProvider.notifier)
          .create(_createCommand());
      final questId = container.read(questFormControllerProvider).value!.id;
      container.read(questFormControllerProvider.notifier).reset();

      final states = <AsyncValue<Quest?>>[];
      final subscription = container.listen(
        questFormControllerProvider,
        (previous, next) => states.add(next),
      );
      addTearDown(subscription.close);

      await container
          .read(questFormControllerProvider.notifier)
          .updateQuest(
            UpdateQuestCommand(
              questId: questId,
              title: 'Renamed',
              description: 'desc',
              type: QuestType.daily,
              difficulty: QuestDifficulty.normal,
              attributeXpWeights: const {AttributeType.health: 60},
              progressType: ProgressType.binary,
              targetProgress: 1,
            ),
          );

      expect(states.any((s) => s.isLoading), isTrue);
      expect(
        container.read(questFormControllerProvider).value?.title,
        'Renamed',
      );
    },
  );

  test('update: a missing quest id surfaces NotFoundFailure', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    await container
        .read(questFormControllerProvider.notifier)
        .updateQuest(
          UpdateQuestCommand(
            questId: 'missing',
            title: 'x',
            description: '',
            type: QuestType.daily,
            difficulty: QuestDifficulty.normal,
            attributeXpWeights: const {AttributeType.health: 60},
            progressType: ProgressType.binary,
            targetProgress: 1,
          ),
        );

    expect(
      container.read(questFormControllerProvider).error,
      isA<NotFoundFailure>(),
    );
  });

  test('resets cleanly back to idle', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questFormControllerProvider.notifier)
        .create(_createCommand());
    expect(container.read(questFormControllerProvider).hasValue, isTrue);

    container.read(questFormControllerProvider.notifier).reset();

    expect(
      container.read(questFormControllerProvider),
      const AsyncData<Quest?>(null),
    );
  });
}
