import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/presentation/suggestion_detail_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

Widget _harness(
  List<Override> overrides, {
  String suggestionId = 'study_pomodoro',
}) {
  final router = GoRouter(
    initialLocation: '/suggestions/$suggestionId',
    routes: [
      GoRoute(
        path: '/suggestions/:suggestionId',
        builder: (context, state) => SuggestionDetailPage(
          suggestionId: state.pathParameters['suggestionId']!,
        ),
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

/// The detail page's `SingleChildScrollView` builds every child eagerly
/// (unlike a virtualizing `ListView`), but `tap()` still needs the target
/// on-screen to hit-test — grown tall enough to fit the whole page without
/// scrolling.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('renders title, description, facts, and an Add action', (
    tester,
  ) async {
    _growViewport(tester);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Study one focused Pomodoro'), findsOneWidget);
    expect(
      find.text('25 minutes of distraction-free study, one clean block.'),
      findsOneWidget,
    );
    expect(
      find.text('Small focused blocks beat long, unfocused sessions.'),
      findsOneWidget,
    );
    expect(find.text('Daily'), findsOneWidget); // repeats
    expect(
      find.widgetWithText(FilledButton, 'Add to My Quests'),
      findsOneWidget,
    );
  });

  testWidgets('shows why-recommended reasons that match the saved profile', (
    tester,
  ) async {
    _growViewport(tester);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      recommendationProfileRepository: FakeRecommendationProfileRepository(
        initial: RecommendationProfile.defaultProfile.copyWith(
          lifeStage: LifeStage.student,
          goals: {GoalArea.study},
        ),
      ),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Why this was recommended'), findsOneWidget);
    expect(find.textContaining('Fits your life stage'), findsOneWidget);
    expect(find.textContaining('Matches your goal: Study'), findsOneWidget);
  });

  testWidgets('shows a generic reason when nothing about the profile matches', (
    tester,
  ) async {
    _growViewport(tester);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      // Deliberately mismatched on every axis against study_pomodoro
      // (student-only, 25 min, normal/balanced difficulty): a non-student
      // life stage, no goals, too little available time, and a mismatched
      // intensity.
      recommendationProfileRepository: FakeRecommendationProfileRepository(
        initial: RecommendationProfile.defaultProfile.copyWith(
          lifeStage: LifeStage.retired,
          availableTime: AvailableTime.under15,
          intensity: PreferredIntensity.challenging,
        ),
      ),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('A solid starting point for anyone.'), findsOneWidget);
  });

  testWidgets('tapping Add to My Quests creates the quest and shows an Open '
      'action that navigates to it', (tester) async {
    _growViewport(tester);
    final questRepository = FakeQuestRepository();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add to My Quests'));
    await tester.pumpAndSettle();

    expect(questRepository.quests.length, 1);
    expect(find.textContaining('Added'), findsOneWidget);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Open'));
    await tester.pumpAndSettle();

    expect(
      find.text('quest-detail:${questRepository.quests.values.first.id}'),
      findsOneWidget,
    );
  });

  testWidgets('shows a not-found state for an unknown suggestion id', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides, suggestionId: 'not-a-real-id'));
    await tester.pumpAndSettle();

    expect(find.text("This suggestion doesn't exist."), findsOneWidget);
  });
}
