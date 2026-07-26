import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/providers/quest_query_providers.dart';
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

/// Polls [condition] until it's true, or fails the test after 2 seconds —
/// avoids depending on a fixed delay to guess how long an async Hive
/// `box.watch()` event takes to propagate.
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

  test('watchAllQuests emits the initial persisted list', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());

    // A persistent listener is required — otherwise this autoDispose stream
    // provider can be torn down by the scheduler before it ever emits, since
    // a bare `read` does not count as an active subscription.
    final subscription = container.listen(
      watchAllQuestsProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final quests = await container.read(watchAllQuestsProvider.future);
    expect(quests.map((q) => q.id), ['q1']);
  });

  test('watchAllQuests emits again after a repository change', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final emissions = <List<Quest>>[];
    final subscription = container.listen(watchAllQuestsProvider, (
      previous,
      next,
    ) {
      final value = next.value;
      if (value != null) emissions.add(value);
    }, fireImmediately: true);
    addTearDown(subscription.close);

    await _waitFor(() => emissions.isNotEmpty);
    expect(emissions.single, isEmpty);

    await container.read(questRepositoryProvider).upsert(_buildQuest());
    await _waitFor(() => emissions.length > 1);

    expect(emissions.last.map((q) => q.id), ['q1']);
  });

  test('questById returns the expected quest', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(questRepositoryProvider).upsert(_buildQuest());

    final quest = await container.read(questByIdProvider('q1').future);
    expect(quest?.id, 'q1');
  });

  test('questById returns null for a missing id', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final quest = await container.read(questByIdProvider('missing').future);
    expect(quest, isNull);
  });

  test('questProgressForDate normalizes the date before querying', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
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

    // Query with a time-of-day component — must still resolve to the same
    // normalized-date row.
    final progress = await container.read(
      questProgressForDateProvider('q1', DateTime.utc(2026, 1, 10, 18)).future,
    );

    expect(progress, isNotNull);
    expect(progress!.isComplete, isTrue);
  });
}
