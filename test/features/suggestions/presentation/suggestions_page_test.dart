import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/suggestions/domain/catalog/quest_suggestion_catalog.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/presentation/suggestions_page.dart';
import 'package:prime/features/suggestions/presentation/widgets/suggestion_card.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/suggestions',
    routes: [
      GoRoute(
        path: '/suggestions',
        builder: (context, state) => const SuggestionsPage(),
        routes: [
          GoRoute(
            path: 'preferences',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('preferences-page'))),
          ),
          GoRoute(
            path: ':suggestionId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  'suggestion-detail:${state.pathParameters['suggestionId']}',
                ),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/quests/:questId',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('quest-detail:${state.pathParameters['questId']}'),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('renders a personalized heading and a grid of suggestion cards', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Popular quests to start with'), findsOneWidget);
    expect(find.byType(SuggestionCard), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Add Quest'), findsWidgets);
  });

  testWidgets('shows the personalized heading once preferences are saved', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      recommendationProfileRepository: FakeRecommendationProfileRepository(
        initial: RecommendationProfile.defaultProfile.copyWith(
          isPersonalized: true,
        ),
      ),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Picked for you'), findsOneWidget);
  });

  testWidgets('the preferences toolbar icon navigates to the editor', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Preferences'));
    await tester.pumpAndSettle();

    expect(find.text('preferences-page'), findsOneWidget);
  });

  testWidgets('tapping a goal filter chip narrows the visible suggestions', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    // "Fitness" is near the start of the horizontally scrolling chip row
    // (GoalArea.fitness is 3rd in declaration order), so it's guaranteed
    // visible without needing to scroll the row first.
    await tester.tap(find.text('Fitness'));
    await tester.pumpAndSettle();

    final visibleCards = tester
        .widgetList<SuggestionCard>(find.byType(SuggestionCard))
        .toList();
    expect(visibleCards, isNotEmpty);
    for (final card in visibleCards) {
      expect(card.suggestion.goals, contains(GoalArea.fitness));
    }
  });

  testWidgets('tapping a suggestion card navigates to its detail route', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    final firstCard = tester
        .widgetList<SuggestionCard>(find.byType(SuggestionCard))
        .first;
    // Invoked directly rather than physically tapped — the card's tap
    // target spans content the "Add Quest" button also occupies part of,
    // and which exact suggestion is first depends on ranking order, not
    // catalog declaration order; this asserts the wiring (tapping the card
    // navigates to *its own* id) without depending on either.
    firstCard.onTap();
    await tester.pumpAndSettle();

    expect(
      find.text('suggestion-detail:${firstCard.suggestion.id}'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Add Quest creates the quest and shows success feedback '
      'with an Open action', (tester) async {
    final questRepository = FakeQuestRepository();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add Quest').first);
    await tester.pumpAndSettle();

    expect(questRepository.quests.length, 1);
    expect(find.textContaining('Added'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'Open'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('quest-detail:${questRepository.quests.values.first.id}'),
      findsOneWidget,
    );
  });

  testWidgets('a double-tap on Add Quest creates at most one quest', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Add Quest').first;
    await tester.tap(addButton);
    await tester.tap(addButton); // second tap while the first is in flight
    await tester.pumpAndSettle();

    expect(questRepository.quests.length, 1);
  });

  testWidgets('shows an empty state once every suggestion has been added', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      recommendationProfileRepository: FakeRecommendationProfileRepository(
        initial: RecommendationProfile.defaultProfile.copyWith(
          acceptedSuggestionIds: {for (final s in questSuggestionCatalog) s.id},
        ),
      ),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(
      find.textContaining("You've added every suggestion"),
      findsOneWidget,
    );
  });
}
