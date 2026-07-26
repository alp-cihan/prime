import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/complete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_query_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../support/hive_test_support.dart';
import '../support/provider_test_support.dart';

Future<void> _waitFor(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Condition was not met within 2 seconds');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
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
    'end-to-end: create a quest, observe it through providers, complete it via the '
    'controller, and see progress + derived XP update in the same container',
    () async {
      // Real, temporary Hive boxes — wired in via the box provider overrides,
      // exactly as production wires them from bootstrapHive(), just pointed
      // at a throwaway directory instead of the app's real one.
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      const quest = Quest(
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

      // Create the quest through the repository provider.
      await container.read(questRepositoryProvider).upsert(quest);

      // Observe it through the quest query providers.
      final questList = container.listen(
        watchAllQuestsProvider,
        (previous, next) {},
      );
      addTearDown(questList.close);
      final quests = await container.read(watchAllQuestsProvider.future);
      expect(quests.map((q) => q.id), ['q1']);
      expect(await container.read(questByIdProvider('q1').future), quest);

      final date = DateTime.utc(2026, 1, 10);
      final progressListener = container.listen(
        questProgressForDateProvider('q1', date),
        (previous, next) {},
      );
      addTearDown(progressListener.close);
      final totalXpListener = container.listen(
        totalXpProvider,
        (previous, next) {},
      );
      addTearDown(totalXpListener.close);
      final byAttributeListener = container.listen(
        xpByAttributeProvider,
        (previous, next) {},
      );
      addTearDown(byAttributeListener.close);

      expect(
        await container.read(questProgressForDateProvider('q1', date).future),
        isNull,
      );
      expect(await container.read(totalXpProvider.future), 0);

      // Execute completion through the controller.
      final command = CompleteQuestCommand(
        questId: 'q1',
        date: date,
        progressValue: 1,
      );
      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(command);

      final controllerState = container.read(completeQuestControllerProvider);
      expect(controllerState.hasValue, isTrue);
      expect(controllerState.value!.totalXpAwarded, 125);

      // Progress and ledger-derived XP update in this same container.
      await _waitFor(
        () =>
            container.read(questProgressForDateProvider('q1', date)).value !=
            null,
      );
      final progress = container
          .read(questProgressForDateProvider('q1', date))
          .value!;
      expect(progress.isComplete, isTrue);

      await _waitFor(() => (container.read(totalXpProvider).value ?? 0) > 0);
      expect(container.read(totalXpProvider).value, 125);

      await _waitFor(() => container.read(xpByAttributeProvider).hasValue);
      final byAttribute = container.read(xpByAttributeProvider).value!;
      expect(
        byAttribute[AttributeType.health],
        75,
      ); // 60 * 1.25 first-completion bonus
      expect(
        byAttribute[AttributeType.strength],
        50,
      ); // 40 * 1.25 first-completion bonus

      // The quest list itself is untouched by completion.
      expect(
        (await container.read(watchAllQuestsProvider.future)).single,
        quest,
      );
    },
  );
}
