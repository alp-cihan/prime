import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/app.dart';
import 'package:prime/core/router/app_routes.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

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

/// Phase 14's own description of the flow a brand-new user must be able to
/// complete: launch, understand the product (onboarding), create a first
/// quest (here: a starter template, onboarding's own offered path), complete
/// it, see XP, and open Identity.
void main() {
  testWidgets(
    'a first-time user launches into onboarding, gets a starter quest, '
    'completes it, earns XP, and opens Identity',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
        onboardingCompleted: false,
      );

      // 1. Launch — a first-time user lands on onboarding, not Today.
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Prime'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing); // outside the shell

      // 2. Walk through the explanation (Next x5 reaches the starter step).
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.widgetWithText(FilledButton, 'Next'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Want a head start?'), findsOneWidget);

      // 3. Select a starter quest and finish onboarding.
      await tester.tap(find.text('Complete a workout'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Add Selected & Get Started'),
      );
      await tester.pumpAndSettle();

      // 4. Landed on Today, with the shell (and its nav) now visible, and
      // the starter quest already showing.
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Complete a workout'), findsWidgets);
      expect(questRepository.quests.length, 1);

      // 5. Complete it and see XP.
      await _goTo(tester, AppRoutes.quests);
      await tester.tap(find.text('Complete a workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+50 XP'), findsOneWidget); // 40 * 1.25

      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // 6. Open Identity and see it reflect the same lifetime XP.
      await _goTo(tester, AppRoutes.identity);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Quests completed'), findsOneWidget);

      await _goTo(tester, AppRoutes.you);
      // 50 from the quest (40 * 1.25 first-completion bonus) + 20 from the
      // "First Step" achievement this first-ever completion also unlocks.
      expect(find.textContaining('70 XP total'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
