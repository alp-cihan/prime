import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/presentation/providers/achievement_evaluation_controller.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/complete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

Quest _buildQuest({
  String id = 'q1',
  QuestDifficulty difficulty = QuestDifficulty.normal,
}) {
  return Quest(
    id: id,
    title: 'Workout',
    description: 'desc',
    type: QuestType.daily,
    difficulty: difficulty,
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

  test('idle at build() with no prior ledger history', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final state = container.read(achievementEvaluationControllerProvider);

    expect(state.pendingUnlocks, isEmpty);
  });

  test('completing a quest through the real completion controller triggers '
      'evaluation and queues the newly-unlocked achievement', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());
    // Establish the controller (and its listeners) before completing —
    // mirrors how the real shell mounts it before any quest is touched.
    container.read(achievementEvaluationControllerProvider);

    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(
          CompleteQuestCommand(
            questId: 'q1',
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        );

    await _waitFor(
      () => container
          .read(achievementEvaluationControllerProvider)
          .pendingUnlocks
          .isNotEmpty,
    );
    final pending = container
        .read(achievementEvaluationControllerProvider)
        .pendingUnlocks;
    expect(pending.map((a) => a.id), contains('first_step'));
  });

  test('acknowledgeFirst pops exactly the front of the queue', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(difficulty: QuestDifficulty.veryHard));
    container.read(achievementEvaluationControllerProvider);

    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(
          CompleteQuestCommand(
            questId: 'q1',
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        );
    // A Very Hard completion satisfies both "First Step" (1 completion) and
    // "Challenger" (a Hard-or-above completion) in the same pass.
    await _waitFor(
      () =>
          container
              .read(achievementEvaluationControllerProvider)
              .pendingUnlocks
              .length >=
          2,
    );
    final before = container
        .read(achievementEvaluationControllerProvider)
        .pendingUnlocks;
    expect(before.length, 2);
    final first = before.first;

    container
        .read(achievementEvaluationControllerProvider.notifier)
        .acknowledgeFirst();

    final after = container
        .read(achievementEvaluationControllerProvider)
        .pendingUnlocks;
    expect(after.length, 1);
    expect(after.single.id, isNot(first.id));
  });

  test('acknowledgeFirst on an empty queue is a harmless no-op', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    container.read(achievementEvaluationControllerProvider);

    expect(
      () => container
          .read(achievementEvaluationControllerProvider.notifier)
          .acknowledgeFirst(),
      returnsNormally,
    );
    expect(
      container.read(achievementEvaluationControllerProvider).pendingUnlocks,
      isEmpty,
    );
  });

  test(
    'a second, already-unlocked-criteria completion does not re-queue it',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      await container
          .read(questRepositoryProvider)
          .upsert(_buildQuest(difficulty: QuestDifficulty.veryHard));
      container.read(achievementEvaluationControllerProvider);

      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(
            CompleteQuestCommand(
              questId: 'q1',
              date: DateTime.utc(2026, 1, 10),
              progressValue: 1,
            ),
          );
      await _waitFor(
        () => container
            .read(achievementEvaluationControllerProvider)
            .pendingUnlocks
            .isNotEmpty,
      );
      // Drain the queue.
      while (container
          .read(achievementEvaluationControllerProvider)
          .pendingUnlocks
          .isNotEmpty) {
        container
            .read(achievementEvaluationControllerProvider.notifier)
            .acknowledgeFirst();
      }

      // A second same-day completion (repeatability: none, so this is
      // rejected by CompleteQuestUseCase) must not resurrect either unlock.
      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(
            CompleteQuestCommand(
              questId: 'q1',
              date: DateTime.utc(2026, 1, 11),
              progressValue: 1,
            ),
          );
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(
        container.read(achievementEvaluationControllerProvider).pendingUnlocks,
        isEmpty,
      );
    },
  );
}
