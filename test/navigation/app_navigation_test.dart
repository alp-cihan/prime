import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/app.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

Quest _buildQuest({String id = 'q1', String title = 'Workout'}) {
  return Quest(
    id: id,
    title: title,
    description: 'Go to the gym',
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

void main() {
  testWidgets('/quests/:questId opens the correct quest', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Workout'), findsOneWidget);

    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Workout'), findsOneWidget);
    expect(find.text('Go to the gym'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unknown quest id does not crash and shows a not-found UI', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/quests/does-not-exist');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining("doesn't exist"), findsOneWidget);
  });

  testWidgets('existing shell navigation across all 5 tabs still works', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);

    await tester.tap(find.byIcon(Icons.checklist_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Quests'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Story'), findsWidgets);

    await tester.tap(find.byIcon(Icons.book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Journal'), findsWidgets);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    // The "You" tab now renders the real XP summary (Phase 5), not the
    // Phase 0 placeholder — its content is "Level N" / "XP by attribute".
    expect(find.textContaining('Level'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '/quests/new opens the create form — "new" is not treated as a quest id',
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      GoRouter.of(context).go('/quests/new');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Create Quest'), findsOneWidget);
      expect(find.textContaining("doesn't exist"), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('/quests/:questId/edit opens a prefilled edit form', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/quests/q1/edit');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Save Changes'), findsOneWidget);
    final titleField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Title'),
    );
    expect(titleField.controller!.text, 'Workout');
    expect(tester.takeException(), isNull);
  });

  testWidgets('/focus remains outside the shell (no bottom nav)', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const PrimeApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/focus');
    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
