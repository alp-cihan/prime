import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/application/models/complete_quest_result.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/presentation/providers/complete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_query_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

Quest _buildQuest({
  String id = 'q1',
  QuestCompletionState state = QuestCompletionState.notStarted,
  Repeatability repeatability = Repeatability.none,
}) {
  return Quest(
    id: id,
    title: 'Workout',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {
      AttributeType.health: 60,
      AttributeType.strength: 40,
    },
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
    repeatability: repeatability,
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

  test('idle -> loading -> success', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);

    final states = <AsyncValue<CompleteQuestResult?>>[];
    final subscription = container.listen(
      completeQuestControllerProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    expect(states.single, const AsyncData<CompleteQuestResult?>(null)); // idle

    final command = CompleteQuestCommand(
      questId: quest.id,
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
    );
    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(command);

    expect(states.any((s) => s.isLoading), isTrue);
    expect(states.last.hasValue, isTrue);
    expect(states.last.value, isNotNull);
    expect(states.last.value!.totalXpAwarded, 125);
  });

  test('idle -> loading -> error', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);

    final states = <AsyncValue<CompleteQuestResult?>>[];
    final subscription = container.listen(
      completeQuestControllerProvider,
      (previous, next) => states.add(next),
    );
    addTearDown(subscription.close);

    final command = CompleteQuestCommand(
      questId: quest.id,
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
      qualityRating: 6, // invalid -> ValidationFailure from the calculator
    );
    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(command);

    expect(states.any((s) => s.isLoading), isTrue);
    expect(states.last.hasError, isTrue);
    expect(states.last.error, isA<ValidationFailure>());
  });

  test('exposes the returned Failure for a missing quest', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final command = CompleteQuestCommand(
      questId: 'missing',
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
    );
    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(command);

    final state = container.read(completeQuestControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.error, isA<NotFoundFailure>());
  });

  test('does not submit twice while a completion is in flight', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);
    final command = CompleteQuestCommand(
      questId: quest.id,
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
    );

    final notifier = container.read(completeQuestControllerProvider.notifier);
    // Both calls are issued synchronously, before either has a chance to
    // await: the second call's `state.isLoading` guard sees the state the
    // first call already set synchronously, and returns immediately.
    final first = notifier.complete(command);
    final second = notifier.complete(command);
    await first;
    await second;

    final transactions = await container
        .read(xpLedgerRepositoryProvider)
        .getAll();
    expect(
      transactions.length,
      2,
    ); // one completion's worth (2 attributes), not 4
  });

  test('resets cleanly back to idle', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);
    final command = CompleteQuestCommand(
      questId: quest.id,
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
    );

    final notifier = container.read(completeQuestControllerProvider.notifier);
    await notifier.complete(command);
    expect(container.read(completeQuestControllerProvider).hasValue, isTrue);

    notifier.reset();
    expect(
      container.read(completeQuestControllerProvider),
      const AsyncData<CompleteQuestResult?>(null),
    );
  });

  test('success refreshes the affected quest progress provider', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);
    final date = DateTime.utc(2026, 1, 10);

    // Keep this provider alive with an active listener so it would show
    // stale (null) data if the controller failed to invalidate it.
    final progressSubscription = container.listen(
      questProgressForDateProvider(quest.id, date),
      (previous, next) {},
    );
    addTearDown(progressSubscription.close);
    expect(
      await container.read(questProgressForDateProvider(quest.id, date).future),
      isNull,
    );

    final command = CompleteQuestCommand(
      questId: quest.id,
      date: date,
      progressValue: 1,
    );
    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(command);

    await _waitFor(
      () =>
          container.read(questProgressForDateProvider(quest.id, date)).value !=
          null,
    );
    expect(
      container
          .read(questProgressForDateProvider(quest.id, date))
          .value!
          .isComplete,
      isTrue,
    );
  });

  test('success refreshes the affected XP providers', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final quest = _buildQuest();
    await container.read(questRepositoryProvider).upsert(quest);
    final date = DateTime.utc(2026, 1, 10);

    final totalSubscription = container.listen(
      totalXpProvider,
      (previous, next) {},
    );
    addTearDown(totalSubscription.close);
    final transactionsSubscription = container.listen(
      xpTransactionsForQuestAndDateProvider(quest.id, date),
      (previous, next) {},
    );
    addTearDown(transactionsSubscription.close);

    expect(await container.read(totalXpProvider.future), 0);
    expect(
      await container.read(
        xpTransactionsForQuestAndDateProvider(quest.id, date).future,
      ),
      isEmpty,
    );

    final command = CompleteQuestCommand(
      questId: quest.id,
      date: date,
      progressValue: 1,
    );
    await container
        .read(completeQuestControllerProvider.notifier)
        .complete(command);

    await _waitFor(() => (container.read(totalXpProvider).value ?? 0) > 0);
    expect(container.read(totalXpProvider).value, 125);
    await _waitFor(
      () =>
          (container
                      .read(
                        xpTransactionsForQuestAndDateProvider(quest.id, date),
                      )
                      .value ??
                  [])
              .isNotEmpty,
    );
    expect(
      container
          .read(xpTransactionsForQuestAndDateProvider(quest.id, date))
          .value!
          .length,
      2,
    );
  });

  test(
    'the controller never writes to Hive directly — only through CompleteQuestUseCase',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final quest = _buildQuest();
      await container.read(questRepositoryProvider).upsert(quest);
      final command = CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      );

      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(command);

      final transactions = await container
          .read(xpLedgerRepositoryProvider)
          .getAll();
      // The exact idempotencyKey format is owned by CompleteQuestUseCase; if
      // the controller ever bypassed it, these would not match.
      expect(transactions.map((t) => t.idempotencyKey).toSet(), {
        'q1|health|2026-01-10|0',
        'q1|strength|2026-01-10|0',
      });
    },
  );

  test(
    'retry after a completed action remains idempotent (a genuine repeat earns diminished, not duplicated, XP)',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      // Repeatability.daily — completing the same quest twice is only
      // allowed for a repeatable quest; a non-repeatable quest is covered
      // separately by complete_quest_use_case_test.dart's "non-repeatable
      // quest lifetime gating" group.
      final quest = _buildQuest(repeatability: Repeatability.daily);
      await container.read(questRepositoryProvider).upsert(quest);
      final command = CompleteQuestCommand(
        questId: quest.id,
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
      );
      final notifier = container.read(completeQuestControllerProvider.notifier);

      await notifier.complete(command);
      expect(
        container.read(completeQuestControllerProvider).value!.totalXpAwarded,
        125,
      );

      notifier.reset();
      await notifier.complete(command);
      expect(
        container.read(completeQuestControllerProvider).value!.totalXpAwarded,
        50,
      );

      final total = await container
          .read(xpLedgerRepositoryProvider)
          .sumLifetimeXp();
      expect(total, 175); // 125 + 50, never inflated or duplicated
    },
  );
}
