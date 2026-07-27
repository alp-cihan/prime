import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/features/quests/application/models/update_quest_progress_result.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/quest_progress_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_query_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

Quest _buildQuest({
  String id = 'q1',
  ProgressType progressType = ProgressType.quantity,
  double targetProgress = 3,
}) {
  return Quest(
    id: id,
    title: 'Read',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.knowledge: 60},
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void main() {
  late HiveTestSupport support;
  final today = DateTime.utc(2026, 1, 10);

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('idle -> loading -> success on increment', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());

    final states = <AsyncValue<UpdateQuestProgressResult?>>[];
    final subscription = container.listen(
      questProgressControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(states.single, const AsyncData<UpdateQuestProgressResult?>(null));

    await container
        .read(questProgressControllerProvider.notifier)
        .increment('q1', today);

    expect(states.any((s) => s.isLoading), isTrue);
    expect(states.last.hasValue, isTrue);
    expect(states.last.value!.newProgress, 1);
    expect(states.last.value!.completed, isFalse);
  });

  test('exposes a completion result when the target is reached', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(targetProgress: 1));

    await container
        .read(questProgressControllerProvider.notifier)
        .increment('q1', today);

    final state = container.read(questProgressControllerProvider);
    expect(state.value!.completed, isTrue);
    expect(state.value!.completionResult, isNotNull);
  });

  test('idle -> loading -> error for an unknown quest', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    await container
        .read(questProgressControllerProvider.notifier)
        .increment('missing', today);

    final state = container.read(questProgressControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NotFoundFailure>());
  });

  test('prevents duplicate submissions while in flight', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(targetProgress: 10));
    final notifier = container.read(questProgressControllerProvider.notifier);

    final first = notifier.increment('q1', today);
    final second = notifier.increment('q1', today);
    await first;
    await second;

    final progress = await container
        .read(questProgressRepositoryProvider)
        .getForQuestAndDate('q1', today);
    expect(progress!.progressValue, 1); // only one of the two landed
  });

  test('decrement reduces progress', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(targetProgress: 10));
    final notifier = container.read(questProgressControllerProvider.notifier);

    await notifier.increment('q1', today, amount: 5);
    notifier.reset();
    await notifier.decrement('q1', today, amount: 2);

    expect(
      container.read(questProgressControllerProvider).value!.newProgress,
      3,
    );
  });

  test('addAmount with a negative value decrements', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(targetProgress: 10));
    final notifier = container.read(questProgressControllerProvider.notifier);

    await notifier.increment('q1', today, amount: 5);
    notifier.reset();
    await notifier.addAmount('q1', today, -2);

    expect(
      container.read(questProgressControllerProvider).value!.newProgress,
      3,
    );
  });

  test('resets cleanly back to idle', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());
    await container
        .read(questProgressControllerProvider.notifier)
        .increment('q1', today);
    expect(container.read(questProgressControllerProvider).hasValue, isTrue);

    container.read(questProgressControllerProvider.notifier).reset();

    expect(
      container.read(questProgressControllerProvider),
      const AsyncData<UpdateQuestProgressResult?>(null),
    );
  });

  test('a completion invalidates the lifetime XP providers', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container
        .read(questRepositoryProvider)
        .upsert(_buildQuest(targetProgress: 1));

    final totalSubscription = container.listen(
      totalXpProvider,
      (previous, next) {},
    );
    addTearDown(totalSubscription.close);
    expect(await container.read(totalXpProvider.future), 0);

    await container
        .read(questProgressControllerProvider.notifier)
        .increment('q1', today);

    expect(await container.read(totalXpProvider.future), greaterThan(0));
  });

  test(
    'a non-completing mutation refreshes questProgressForDateProvider without touching XP providers',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      await container
          .read(questRepositoryProvider)
          .upsert(_buildQuest(targetProgress: 10));

      final progressSubscription = container.listen(
        questProgressForDateProvider('q1', today),
        (previous, next) {},
      );
      addTearDown(progressSubscription.close);
      expect(
        await container.read(questProgressForDateProvider('q1', today).future),
        isNull,
      );

      await container
          .read(questProgressControllerProvider.notifier)
          .increment('q1', today);

      final refreshed = await container.read(
        questProgressForDateProvider('q1', today).future,
      );
      expect(refreshed!.progressValue, 1);
      expect(await container.read(totalXpProvider.future), 0);
    },
  );
}
