import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/application/models/complete_quest_command.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/providers/complete_quest_controller.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/today/presentation/providers/today_dashboard_providers.dart';

import '../../../../support/fake_repositories.dart';
import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

/// Fixed so it matches every completion command's `date` below — the
/// dashboard providers derive "today" from [todayUtcProvider] (backed by
/// [clockProvider]), not from whatever a command happens to pass in, so the
/// test's notion of "today" must be pinned to the same value.
final _today = DateTime.utc(2026, 1, 10);

Future<ProviderContainer> _buildTodayContainer() => buildTestContainer(
  extraOverrides: [clockProvider.overrideWithValue(FakeClock(_today))],
);

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

  group('todayQuestProgressSummary', () {
    test(
      'zero active quests yields a zero completion ratio, not a divide-by-zero',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final subscription = container.listen(
          todayQuestProgressSummaryProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final summary = await container.read(
          todayQuestProgressSummaryProvider.future,
        );

        expect(summary.totalActiveQuests, 0);
        expect(summary.completedToday, 0);
        expect(summary.completionRatio, 0.0);
      },
    );

    test('counts completed vs incomplete active quests correctly', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest(id: 'q1'));
      await questRepository.upsert(_buildQuest(id: 'q2'));
      await questRepository.upsert(_buildQuest(id: 'q3'));

      final subscription = container.listen(
        todayQuestProgressSummaryProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final command = CompleteQuestCommand(
        questId: 'q1',
        date: _today,
        progressValue: 1,
      );
      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(command);

      await _waitFor(() {
        final value = container.read(todayQuestProgressSummaryProvider).value;
        return value != null && value.completedToday == 1;
      });

      final summary = container.read(todayQuestProgressSummaryProvider).value!;
      expect(summary.totalActiveQuests, 3);
      expect(summary.completedToday, 1);
      expect(summary.completionRatio, closeTo(1 / 3, 0.0001));
    });

    test(
      'expired/converted quests are excluded from the active count',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1'));
        await questRepository.upsert(
          _buildQuest(id: 'q2', state: QuestCompletionState.expired),
        );
        await questRepository.upsert(
          _buildQuest(id: 'q3', state: QuestCompletionState.converted),
        );
        final subscription = container.listen(
          todayQuestProgressSummaryProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final summary = await container.read(
          todayQuestProgressSummaryProvider.future,
        );
        expect(summary.totalActiveQuests, 1);
      },
    );
  });

  group('featuredQuest', () {
    test('returns null when there are no quests', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        featuredQuestProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final quest = await container.read(featuredQuestProvider.future);
      expect(quest, isNull);
    });

    test('selects the first incomplete active quest', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest(id: 'q1', title: 'First'));
      await questRepository.upsert(_buildQuest(id: 'q2', title: 'Second'));

      final subscription = container.listen(
        featuredQuestProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final command = CompleteQuestCommand(
        questId: 'q1',
        date: _today,
        progressValue: 1,
      );
      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(command);

      await _waitFor(() {
        final value = container.read(featuredQuestProvider).value;
        return value?.id == 'q2';
      });
    });

    test(
      'falls back to the first active quest once all are complete',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1', title: 'Only'));

        final subscription = container.listen(
          featuredQuestProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final command = CompleteQuestCommand(
          questId: 'q1',
          date: _today,
          progressValue: 1,
        );
        await container
            .read(completeQuestControllerProvider.notifier)
            .complete(command);

        await _waitFor(() {
          final value = container.read(featuredQuestProvider).value;
          return value?.id == 'q1';
        });
      },
    );
  });

  group('continueQuest (Phase 18)', () {
    test('returns null when there are no quests', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        continueQuestProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final quest = await container.read(continueQuestProvider.future);
      expect(quest, isNull);
    });

    test('returns null when the only quest is the featured one', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest(id: 'q1', title: 'Only'));
      final subscription = container.listen(
        continueQuestProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final quest = await container.read(continueQuestProvider.future);
      expect(quest, isNull);
    });

    test(
      'returns null for a binary second quest (no measurable progress)',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1', title: 'Featured'));
        await questRepository.upsert(
          _buildQuest(id: 'q2', title: 'Binary too'),
        );
        final subscription = container.listen(
          continueQuestProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final quest = await container.read(continueQuestProvider.future);
        expect(quest, isNull);
      },
    );

    test(
      'returns null for a non-binary second quest with zero progress today',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1', title: 'Featured'));
        await questRepository.upsert(
          Quest(
            id: 'q2',
            title: 'Read',
            description: '',
            type: QuestType.daily,
            difficulty: QuestDifficulty.normal,
            attributeXpWeights: const {AttributeType.knowledge: 30},
            linkedIdentityStatementIds: const [],
            progressType: ProgressType.quantity,
            currentProgress: 0,
            targetProgress: 20,
            prerequisiteQuestIds: const [],
            state: QuestCompletionState.notStarted,
            failureBehavior: FailureBehavior.expire,
          ),
        );
        final subscription = container.listen(
          continueQuestProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final quest = await container.read(continueQuestProvider.future);
        expect(quest, isNull);
      },
    );

    test('selects a second, non-featured, non-binary quest with progress > 0 '
        'that is not yet complete', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest(id: 'q1', title: 'Featured'));
      await questRepository.upsert(
        Quest(
          id: 'q2',
          title: 'Read',
          description: '',
          type: QuestType.daily,
          difficulty: QuestDifficulty.normal,
          attributeXpWeights: const {AttributeType.knowledge: 30},
          linkedIdentityStatementIds: const [],
          progressType: ProgressType.quantity,
          currentProgress: 0,
          targetProgress: 20,
          prerequisiteQuestIds: const [],
          state: QuestCompletionState.inProgress,
          failureBehavior: FailureBehavior.expire,
        ),
      );
      final progressRepository = container.read(
        questProgressRepositoryProvider,
      );
      await progressRepository.upsert(
        QuestProgress(
          questId: 'q2',
          date: _today,
          progressValue: 12,
          isComplete: false,
        ),
      );
      final subscription = container.listen(
        continueQuestProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final quest = await container.read(continueQuestProvider.future);
      expect(quest?.id, 'q2');
    });

    test(
      'never returns the same quest featuredQuest already selected',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        // Only one quest exists, and it has partial (non-binary) progress —
        // without the featured-quest exclusion this would wrongly also
        // become the Continue pick.
        await questRepository.upsert(
          Quest(
            id: 'q1',
            title: 'Read',
            description: '',
            type: QuestType.daily,
            difficulty: QuestDifficulty.normal,
            attributeXpWeights: const {AttributeType.knowledge: 30},
            linkedIdentityStatementIds: const [],
            progressType: ProgressType.quantity,
            currentProgress: 0,
            targetProgress: 20,
            prerequisiteQuestIds: const [],
            state: QuestCompletionState.inProgress,
            failureBehavior: FailureBehavior.expire,
          ),
        );
        final progressRepository = container.read(
          questProgressRepositoryProvider,
        );
        await progressRepository.upsert(
          QuestProgress(
            questId: 'q1',
            date: _today,
            progressValue: 12,
            isComplete: false,
          ),
        );
        final subscription = container.listen(
          continueQuestProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final featured = await container.read(featuredQuestProvider.future);
        final continueQuest = await container.read(
          continueQuestProvider.future,
        );
        expect(featured?.id, 'q1');
        expect(continueQuest, isNull);
      },
    );

    test(
      'excludes a completed second quest even with prior progress',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1', title: 'Featured'));
        await questRepository.upsert(
          Quest(
            id: 'q2',
            title: 'Read',
            description: '',
            type: QuestType.daily,
            difficulty: QuestDifficulty.normal,
            attributeXpWeights: const {AttributeType.knowledge: 30},
            linkedIdentityStatementIds: const [],
            progressType: ProgressType.quantity,
            currentProgress: 0,
            targetProgress: 20,
            prerequisiteQuestIds: const [],
            state: QuestCompletionState.complete,
            failureBehavior: FailureBehavior.expire,
          ),
        );
        final progressRepository = container.read(
          questProgressRepositoryProvider,
        );
        await progressRepository.upsert(
          QuestProgress(
            questId: 'q2',
            date: _today,
            progressValue: 20,
            isComplete: true,
          ),
        );
        final subscription = container.listen(
          continueQuestProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final quest = await container.read(continueQuestProvider.future);
        expect(quest, isNull);
      },
    );
  });

  group('today XP providers', () {
    test('todayXpTotal sums only today\'s transactions', () async {
      final container = await _buildTodayContainer();
      addTearDown(container.dispose);
      final questRepository = container.read(questRepositoryProvider);
      await questRepository.upsert(_buildQuest(id: 'q1'));
      final subscription = container.listen(
        todayXpTotalProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      final command = CompleteQuestCommand(
        questId: 'q1',
        date: _today,
        progressValue: 1,
      );
      await container
          .read(completeQuestControllerProvider.notifier)
          .complete(command);

      await _waitFor(() {
        final value = container.read(todayXpTotalProvider).value;
        return value != null && value > 0;
      });
      expect(container.read(todayXpTotalProvider).value, 75); // 60 * 1.25
    });

    test(
      'todayXpByAttribute groups by attribute and omits zero entries',
      () async {
        final container = await _buildTodayContainer();
        addTearDown(container.dispose);
        final questRepository = container.read(questRepositoryProvider);
        await questRepository.upsert(_buildQuest(id: 'q1'));
        final subscription = container.listen(
          todayXpByAttributeProvider,
          (previous, next) {},
        );
        addTearDown(subscription.close);

        final command = CompleteQuestCommand(
          questId: 'q1',
          date: _today,
          progressValue: 1,
        );
        await container
            .read(completeQuestControllerProvider.notifier)
            .complete(command);

        await _waitFor(() {
          final value = container.read(todayXpByAttributeProvider).value;
          return value != null && value.isNotEmpty;
        });
        final byAttribute = container.read(todayXpByAttributeProvider).value!;
        expect(byAttribute[AttributeType.health], 75);
        expect(byAttribute.containsKey(AttributeType.strength), isFalse);
      },
    );
  });
}
