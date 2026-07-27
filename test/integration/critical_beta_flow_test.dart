import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/app.dart';
import 'package:prime/core/router/app_routes.dart';
import 'package:prime/features/quests/presentation/widgets/quest_card.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

/// The app has more content than the default test surface, and several
/// screens are `SingleChildScrollView`s — enlarged so every control stays
/// reachable without per-step scrolling (same rationale as
/// `quest_crud_widget_flow_test.dart`).
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _goTo(WidgetTester tester, String path) async {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(path);
  await tester.pumpAndSettle();
}

/// Same reasoning as `quest_crud_widget_flow_test.dart`'s `_openDetail`:
/// invokes the card's own `onTap` rather than a simulated tap, sidestepping
/// this environment's overlay-artifact hit-test flakiness on repeated
/// navigation round-trips.
Future<void> _openDetail(WidgetTester tester, String title) async {
  await _goTo(tester, AppRoutes.quests);
  final card = tester.widget<QuestCard>(find.widgetWithText(QuestCard, title));
  card.onTap();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'critical beta flow: launch, create a quest, complete it, earn XP, see '
    'the achievement unlock, and view the Identity Profile',
    (tester) async {
      _growViewport(tester);
      // Fake repositories, not real Hive — `quest_progress_full_flow_test.dart`
      // documents that combining `testWidgets` with a real, disk-backed Hive
      // box hangs indefinitely in this environment. This test therefore
      // covers the full *UI* journey; "restart reproduces identical,
      // persisted results" for this exact shape of flow (complete a quest,
      // unlock an achievement, then derive an Identity snapshot) is verified
      // separately, against real temporary Hive boxes with no widget tree
      // involved, by `test/integration/identity_full_flow_test.dart`.
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      // 1. Launch the app.
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsWidgets);
      expect(tester.takeException(), isNull);

      // 2. Create a quest through the real form.
      await _goTo(tester, AppRoutes.quests);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Morning workout',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '80',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Morning workout'), findsOneWidget);

      // 3 & 4. Complete it (binary quest — this is also "update progress"
      // for a binary quest, per the app's own domain model) and receive XP.
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+100 XP'), findsOneWidget); // 80 * 1.25

      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // 5. View the achievement if one unlocked — completing a first-ever
      // quest unlocks "First Step" ("complete your first quest"), shown as
      // an auto-popup dialog from the shell. Achievement evaluation runs as
      // a fire-and-forget async pass after completion (see
      // `AchievementEvaluationController`), so give it a couple more settle
      // rounds before deciding whether a dialog needs dismissing.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      if (find.text('ACHIEVEMENT UNLOCKED').evaluate().isNotEmpty) {
        // Same reasoning as `quest_crud_widget_flow_test.dart`'s
        // `_openDetail`: by this point in the flow, an accumulated overlay
        // entry can absorb a simulated tap before it reaches the real
        // button, so the dialog's own dismiss action is invoked directly.
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Nice'))
            .onPressed!();
        await tester.pumpAndSettle();
      }
      await _goTo(tester, AppRoutes.achievements);
      expect(find.text('First Step'), findsOneWidget);
      expect(find.textContaining('Unlocked'), findsWidgets);

      // 6. Open the Identity Profile and confirm it reflects everything so
      // far, entirely derived (no separate entry needed).
      await _goTo(tester, AppRoutes.identity);
      expect(find.textContaining('Level'), findsWidgets);
      expect(find.text('Quests completed'), findsOneWidget);
      expect(find.textContaining('Unlocked "First Step"'), findsOneWidget);

      // 7. The quest, its completion, and the XP total remain consistent
      // everywhere else in the app too.
      await _openDetail(tester, 'Morning workout');
      expect(find.text('Quest complete for today'), findsOneWidget);

      await _goTo(tester, AppRoutes.you);
      // 100 from the quest (80 * 1.25 first-completion bonus) + 20 from the
      // "First Step" achievement reward.
      expect(find.textContaining('120 XP total'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
