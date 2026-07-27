import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/app.dart';
import 'package:prime/core/router/app_routes.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Same reasoning as `quest_crud_widget_flow_test.dart`'s `_goTo` — driving
/// tab/list navigation through the router directly rather than tapping the
/// bottom `NavigationBar` avoids this environment's known hit-test
/// flakiness (a transient overlay — e.g. the completion SnackBar's route —
/// can intercept a `tester.tap` at a given screen position for a stretch of
/// pumps after it's shown).
Future<void> _goTo(WidgetTester tester, String path) async {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(path);
  await tester.pumpAndSettle();
}

/// Invokes the Quests list's Create Quest FAB directly instead of
/// `tester.tap`. The *first* FAB tap in this test is a real
/// `tester.tap(find.byType(FloatingActionButton))` (see below) and works
/// fine; by the second and third rounds (after a full create+complete
/// cycle has run), the same overlay-accumulation hit-test flakiness
/// documented in `quest_crud_widget_flow_test.dart` reappears here for the
/// FAB specifically — confirmed via the "derived an Offset that would not
/// hit test" warning immediately followed by the tap silently missing.
/// Calling `onPressed` directly still exercises the exact navigation the
/// real widget wires up; it only skips simulated hit-testing.
void _tapFab(WidgetTester tester) {
  tester
      .widget<FloatingActionButton>(find.byType(FloatingActionButton))
      .onPressed!();
}

/// Selects a progress type by invoking the dropdown's `onChanged` directly
/// instead of simulating open-then-tap-item. The second progress-type
/// dropdown interaction in this test hit the same accumulated-overlay
/// flakiness as `_tapFab` above (confirmed the same way: a hit-test-miss
/// warning immediately followed by "Bad state: No element" once a
/// subsequent finder came up empty because the tap never actually landed).
void _selectProgressType(WidgetTester tester, ProgressType type) {
  tester
      .widget<DropdownButtonFormField<ProgressType>>(
        find.byType(DropdownButtonFormField<ProgressType>),
      )
      .onChanged!(type);
}

/// Same reasoning as `_tapFab`/`_selectProgressType` — the "Create Quest"
/// submit button hit the identical flakiness on its third occurrence.
void _tapCreateQuestButton(WidgetTester tester) {
  tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, 'Create Quest'))
      .onPressed!();
}

/// Same reasoning again — by the duration quest (the third quest, deep into
/// this test's navigation history), even a first-ever tap on a freshly
/// built button (the quick-add buttons here) can land on an accumulated
/// overlay instead. `FilledButton.tonalIcon` still produces a `FilledButton`
/// instance, so it's found the same way as `_tapCreateQuestButton`.
void _tapQuickAddButton(WidgetTester tester, String label) {
  tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, label))
      .onPressed!();
}

void main() {
  testWidgets(
    'create a binary, a quantity, and a duration quest and complete each '
    'through its real controls, with XP awarded exactly once per quest',
    (tester) async {
      _growViewport(tester);
      // Fake repositories, matching `quest_crud_widget_flow_test.dart`
      // (Phase 7) — combining `testWidgets` with a real, disk-backed Hive
      // box turned out to hang indefinitely in this environment (verified:
      // `await tester.pumpWidget(...)` for `PrimeApp` never returned, even
      // over a 10-minute timeout, with no other passing test in this
      // codebase combining `testWidgets` and `HiveTestSupport`). The
      // "survives a restart" guarantee this flow would otherwise also cover
      // is verified separately, against real temporary Hive boxes with no
      // widget tree involved, by
      // `test/integration/quest_progress_persistence_integration_test.dart`
      // and `test/integration/quest_mutation_persistence_integration_test.dart`.
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

      // ── 1-3. Binary quest: create, complete, XP awarded once. ──────────
      await _goTo(tester, AppRoutes.quests);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Stretch',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '50',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Stretch'), findsOneWidget);

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+63 XP'), findsOneWidget); // round(50*1.25)
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // ── 4-6. Quantity quest: create, increment to target, XP once. ─────
      await _goTo(tester, AppRoutes.quests);
      _tapFab(tester);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Drink water',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '40',
      );
      // Progress type: Binary -> Quantity.
      _selectProgressType(tester, ProgressType.quantity);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target progress'),
        '5',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Drink water'), findsOneWidget);

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byTooltip('Increase by 1'));
        await tester.pumpAndSettle();
      }
      expect(find.text('5 / 5'), findsOneWidget);
      expect(find.textContaining('+50 XP'), findsOneWidget); // 40*1.25
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // ── 7-9. Duration quest: create, add minutes to target, XP once. ───
      await _goTo(tester, AppRoutes.quests);
      _tapFab(tester);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Meditate',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '30',
      );
      _selectProgressType(tester, ProgressType.duration);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target progress'),
        '30',
      );
      _tapCreateQuestButton(tester);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Meditate'), findsOneWidget);

      _tapQuickAddButton(tester, '15 min');
      await tester.pumpAndSettle();
      _tapQuickAddButton(tester, '15 min');
      await tester.pumpAndSettle();
      expect(find.text('30 / 30 min'), findsOneWidget);
      expect(find.textContaining('+38 XP'), findsOneWidget); // round(30*1.25)
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // 63 + 50 + 38 = 151 — one award per quest, none duplicated.
      await _goTo(tester, AppRoutes.you);
      expect(find.textContaining('151 XP total'), findsOneWidget);

      // Live, correct progress on the Quests list for all three types.
      await _goTo(tester, AppRoutes.quests);
      expect(find.text('Completed today'), findsOneWidget); // Stretch
      expect(find.text('5 / 5'), findsOneWidget); // Drink water
      expect(find.text('30 min / 30 min'), findsOneWidget); // Meditate

      // And on the Today dashboard.
      await _goTo(tester, AppRoutes.today);
      expect(find.textContaining('3 of 3 quests completed'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
