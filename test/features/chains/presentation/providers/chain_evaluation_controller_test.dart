import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/presentation/providers/chain_evaluation_controller.dart';
import 'package:prime/features/chains/presentation/providers/chain_repository_providers.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/complete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

const _chain = Chain(
  id: 'chain1',
  title: 'Chain 1',
  description: 'desc',
  iconKey: 'book',
  questIds: ['q1', 'q2'],
  rewardXp: 25,
  sortOrder: 0,
);

Quest _buildQuest(String id) {
  return Quest(
    id: id,
    title: 'Quest $id',
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

/// Polls an async condition — needed because the controller's evaluation
/// runs in a fire-and-forget microtask/listener callback, not something
/// `complete()`'s own await chain waits for.
Future<void> _waitForAsync(Future<bool> Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!await condition()) {
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

  Future<ProviderContainer> buildContainer() async => buildTestContainer(
    extraOverrides: [
      chainCatalogListProvider.overrideWithValue([_chain]),
    ],
  );

  test('idle at build() with no prior ledger history', () async {
    final container = await buildContainer();
    addTearDown(container.dispose);

    final state = container.read(chainEvaluationControllerProvider);

    expect(state.recentlyCompleted, isEmpty);
  });

  test('completing a chain-member quest through the real completion controller '
      'advances the chain automatically', () async {
    final container = await buildContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest('q1'));
    container.read(chainEvaluationControllerProvider);
    final repository = container.read(chainProgressRepositoryProvider);

    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(
          CompleteQuestCommand(
            questId: 'q1',
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        );

    await _waitForAsync(() async {
      final progress = await repository.getForChain('chain1');
      return progress?.completedStageCount == 1;
    });
  });

  test(
    'completing the final quest marks the chain as recently completed',
    () async {
      final container = await buildContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest('q1'));
      await questRepository.upsert(_buildQuest('q2'));
      container.read(chainEvaluationControllerProvider);
      final repository = container.read(chainProgressRepositoryProvider);

      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(
            CompleteQuestCommand(
              questId: 'q1',
              date: DateTime.utc(2026, 1, 10),
              progressValue: 1,
            ),
          );
      await _waitForAsync(() async {
        final progress = await repository.getForChain('chain1');
        return progress?.completedStageCount == 1;
      });

      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(
            CompleteQuestCommand(
              questId: 'q2',
              date: DateTime.utc(2026, 1, 10),
              progressValue: 1,
            ),
          );

      await _waitForAsync(
        () async => container
            .read(chainEvaluationControllerProvider)
            .recentlyCompleted
            .isNotEmpty,
      );
      final completed = container
          .read(chainEvaluationControllerProvider)
          .recentlyCompleted;
      expect(completed.map((c) => c.id), ['chain1']);
      final progress = await repository.getForChain('chain1');
      expect(progress?.completedAt, isNotNull);
    },
  );

  test('completing an unrelated quest does not advance the chain', () async {
    final container = await buildContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest('unrelated'));
    container.read(chainEvaluationControllerProvider);

    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(
          CompleteQuestCommand(
            questId: 'unrelated',
            date: DateTime.utc(2026, 1, 10),
            progressValue: 1,
          ),
        );
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final progress = await container
        .read(chainProgressRepositoryProvider)
        .getForChain('chain1');
    expect(progress, isNull);
  });
}
