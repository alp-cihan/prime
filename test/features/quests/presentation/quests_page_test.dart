import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/quests_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';
import '../../../support/widget_test_harness.dart';

Quest _buildQuest({
  String id = 'q1',
  String title = 'Workout',
  String description = 'Go to the gym',
}) {
  return Quest(
    id: id,
    title: title,
    description: description,
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
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/quests',
    routes: [
      GoRoute(
        path: '/quests',
        builder: (context, state) => const QuestsPage(),
        routes: [
          // Declared before `:questId`, matching the real router, so
          // `/quests/new` never gets captured as `:questId = "new"`.
          GoRoute(
            path: 'new',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('create-form'))),
          ),
          GoRoute(
            path: ':questId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('detail:${state.pathParameters['questId']}'),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/suggestions',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('suggestions-page'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
    ),
  );
}

void main() {
  testWidgets('shows a loading indicator before the stream emits', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty-state message when there are no quests', (
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

    expect(find.textContaining('No quests yet'), findsOneWidget);
  });

  testWidgets('renders persisted quests from watchAllQuestsProvider', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Go to the gym'), findsOneWidget);
    expect(find.textContaining('100 XP'), findsOneWidget); // 60 + 40
  });

  testWidgets('tapping a quest navigates to its detail route', (tester) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.text('detail:q1'), findsOneWidget);
  });

  testWidgets('the Create Quest action is visible in the empty state', (
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

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create Quest'), findsOneWidget);
  });

  testWidgets('the Create Quest action is visible when quests exist', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('tapping the Create Quest FAB navigates to /quests/new', (
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

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('create-form'), findsOneWidget);
  });

  testWidgets('the Suggestions entry point is visible and reachable from the '
      'empty state', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(OutlinedButton, 'Browse Suggestions'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Browse Suggestions'));
    await tester.pumpAndSettle();

    expect(find.text('suggestions-page'), findsOneWidget);
  });

  testWidgets('the Suggestions entry point is always visible, even with '
      'quests present', (tester) async {
    final questRepository = FakeQuestRepository()..quests['q1'] = _buildQuest();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Suggestions'));
    await tester.pumpAndSettle();

    expect(find.text('suggestions-page'), findsOneWidget);
  });
}
