import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/providers/quest_query_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/presentation/providers/ranked_suggestions_provider.dart';
import 'package:prime/features/suggestions/presentation/providers/recommendation_profile_controller.dart';
import 'package:prime/features/suggestions/presentation/providers/suggestion_creation_controller.dart';
import 'package:prime/features/suggestions/presentation/providers/suggestion_filter_controller.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

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

  test('initially contains the entire catalog', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      rankedSuggestionsProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final ranked = await container.read(rankedSuggestionsProvider.future);

    expect(ranked.length, questSuggestionCatalog.length);
  });

  test('creating a quest from a suggestion removes it from the ranked list — '
      'the same underlying quest stream Quests/Today already watch', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      rankedSuggestionsProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    await container.read(rankedSuggestionsProvider.future);
    final target = questSuggestionCatalog.first;

    await container
        .read(suggestionCreationControllerProvider(target.id).notifier)
        .create(target);

    await _waitFor(() {
      final value = container.read(rankedSuggestionsProvider).value;
      return value != null && value.length == questSuggestionCatalog.length - 1;
    });
    final ranked = container.read(rankedSuggestionsProvider).value!;
    expect(ranked.map((s) => s.id), isNot(contains(target.id)));

    // Verify against the exact provider Quests/Today read from.
    final quests = await container.read(watchAllQuestsProvider.future);
    expect(quests.map((q) => q.title), contains(target.title));
  });

  test(
    'a manually created quest with a matching title also excludes the '
    'suggestion, without going through the suggestions flow at all',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(
        rankedSuggestionsProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);
      final target = questSuggestionCatalog.first;

      await container
          .read(questRepositoryProvider)
          .upsert(_fakeQuestWithTitle(target.title));

      await _waitFor(() {
        final value = container.read(rankedSuggestionsProvider).value;
        return value != null &&
            value.length == questSuggestionCatalog.length - 1;
      });
      final ranked = container.read(rankedSuggestionsProvider).value!;
      expect(ranked.map((s) => s.id), isNot(contains(target.id)));
    },
  );

  test('toggling a goal filter narrows the ranked list', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      rankedSuggestionsProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    await container.read(rankedSuggestionsProvider.future);

    container
        .read(suggestionFilterControllerProvider.notifier)
        .toggle(GoalArea.finance);

    await _waitFor(() {
      final value = container.read(rankedSuggestionsProvider).value;
      return value != null &&
          value.isNotEmpty &&
          value.every((s) => s.goals.contains(GoalArea.finance));
    });
  });

  test('saving a new profile reorders the ranked list', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final rankedSub = container.listen(
      rankedSuggestionsProvider,
      (previous, next) {},
    );
    addTearDown(rankedSub.close);
    final profileSub = container.listen(
      recommendationProfileControllerProvider,
      (previous, next) {},
    );
    addTearDown(profileSub.close);
    final before = await container.read(rankedSuggestionsProvider.future);
    await container.read(recommendationProfileControllerProvider.future);

    await container
        .read(recommendationProfileControllerProvider.notifier)
        .save(
          RecommendationProfile.defaultProfile.copyWith(
            lifeStage: LifeStage.student,
            goals: {GoalArea.study},
          ),
        );

    await _waitFor(() {
      final value = container.read(rankedSuggestionsProvider).value;
      return value != null && value.first.id != before.first.id;
    });
    final after = container.read(rankedSuggestionsProvider).value!;
    expect(after.first.goals, contains(GoalArea.study));
  });
}

Quest _fakeQuestWithTitle(String title) {
  return Quest(
    id: title,
    title: title,
    description: '',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 20},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}
