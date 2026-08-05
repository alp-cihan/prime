import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/suggestions/application/models/create_quest_from_suggestion_outcome.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/presentation/providers/suggestion_creation_controller.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('idle -> loading -> success creates exactly one quest', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final suggestion = questSuggestionCatalog.first;

    final states = <AsyncValue<CreateQuestFromSuggestionOutcome?>>[];
    final subscription = container.listen(
      suggestionCreationControllerProvider(suggestion.id),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container
        .read(suggestionCreationControllerProvider(suggestion.id).notifier)
        .create(suggestion);

    expect(states.any((s) => s.isLoading), isTrue);
    final outcome = container
        .read(suggestionCreationControllerProvider(suggestion.id))
        .value;
    expect(outcome, isA<SuggestionQuestCreated>());

    final quests = await container.read(questRepositoryProvider).getAll();
    expect(quests.where((q) => q.title == suggestion.title).length, 1);
  });

  test(
    'two concurrent taps on the same suggestion create at most one quest',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final suggestion = questSuggestionCatalog[1];
      final notifier = container.read(
        suggestionCreationControllerProvider(suggestion.id).notifier,
      );

      final first = notifier.create(suggestion);
      final second = notifier.create(suggestion); // guarded no-op
      await first;
      await second;

      final quests = await container.read(questRepositoryProvider).getAll();
      expect(quests.where((q) => q.title == suggestion.title).length, 1);
    },
  );

  test(
    'two different suggestions each have independent loading state',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final a = questSuggestionCatalog[0];
      final b = questSuggestionCatalog[1];

      await container
          .read(suggestionCreationControllerProvider(a.id).notifier)
          .create(a);

      // b's controller is untouched by a's creation.
      expect(
        container.read(suggestionCreationControllerProvider(b.id)).value,
        isNull,
      );
    },
  );

  test('resets cleanly back to idle', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final suggestion = questSuggestionCatalog.first;
    await container
        .read(suggestionCreationControllerProvider(suggestion.id).notifier)
        .create(suggestion);

    container
        .read(suggestionCreationControllerProvider(suggestion.id).notifier)
        .reset();

    expect(
      container.read(suggestionCreationControllerProvider(suggestion.id)),
      const AsyncData<CreateQuestFromSuggestionOutcome?>(null),
    );
  });
}
