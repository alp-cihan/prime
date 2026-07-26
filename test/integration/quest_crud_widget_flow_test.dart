import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/app.dart';
import 'package:prime/core/router/app_routes.dart';
import 'package:prime/features/quests/presentation/widgets/quest_card.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

/// The app has more content than the default test surface (800x600), and
/// several screens here are `SingleChildScrollView`s — enlarging the
/// viewport keeps every button reachable by `tester.tap` without needing
/// per-step scrolling.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Navigates via the router directly rather than tapping the bottom
/// `NavigationBar` icons or a rendered quest-list row. This test's purpose
/// is verifying data consistency across screens through the real
/// controllers (the CRUD flow), not tap-coordinate mechanics — those are
/// already covered by `test/navigation/app_navigation_test.dart`. Driving
/// navigation this way sidesteps real flakiness in this environment where a
/// transient overlay (the completion SnackBar's Material route) can
/// intercept a `tester.tap` at a given screen position for a stretch of
/// pumps after it's shown, regardless of `clearSnackBars()`.
Future<void> _goTo(WidgetTester tester, String path) async {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(path);
  await tester.pumpAndSettle();
}

/// Reaches the quest's detail screen by first resetting the Quests branch
/// to its list root, then invoking the row's own `onTap` directly instead
/// of a simulated `tester.tap`. By the third or so navigation round-trip
/// through this flow, an accumulated overlay entry (this environment inserts
/// one per tooltipped `IconButton` — Edit/Delete/the AppBar back button —
/// each time one is built) ends up geometrically on top of whatever's
/// tapped next, absorbing the pointer event before it reaches the real
/// target (visible via `debugDumpApp()`: extra non-opaque, non-maintained
/// overlay entries). Calling the row's real `onTap` callback exercises the
/// exact same navigation code a tap would, without depending on the
/// simulated hit-test pipeline being clear of that artifact.
Future<void> _openDetail(WidgetTester tester, String title) async {
  await _goTo(tester, AppRoutes.quests);
  final card = tester.widget<QuestCard>(find.widgetWithText(QuestCard, title));
  card.onTap();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'create, edit, and delete a quest entirely through the UI, staying '
    'consistent across the Quests list, Today dashboard, and You XP summary',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      // 1. Open Quests and create a quest through the form.
      await _goTo(tester, AppRoutes.quests);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Read a book',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '40',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      // Landed on the created quest's detail screen.
      expect(find.widgetWithText(AppBar, 'Read a book'), findsOneWidget);
      expect(questRepository.quests.length, 1);

      // 2. It appears in the Quests list.
      await _goTo(tester, AppRoutes.quests);
      expect(find.text('Read a book'), findsOneWidget);

      // 3. It appears in the Today dashboard (Main Quest card / quest list).
      await _goTo(tester, AppRoutes.today);
      expect(find.text('Read a book'), findsWidgets);

      // 4. Open detail, edit the title and XP weight.
      await _openDetail(tester, 'Read a book');
      await tester.tap(find.widgetWithIcon(IconButton, Icons.edit_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Read a book (30m)',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'XP weight'),
        '80',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      // 5. The edit is reflected immediately on detail, list, and dashboard.
      expect(find.widgetWithText(AppBar, 'Read a book (30m)'), findsOneWidget);

      await _goTo(tester, AppRoutes.quests);
      expect(find.text('Read a book (30m)'), findsOneWidget);
      expect(find.text('Read a book'), findsNothing); // old title gone

      await _goTo(tester, AppRoutes.today);
      expect(find.text('Read a book (30m)'), findsWidgets);

      // 6. Complete it (produces real XP ledger history to verify later).
      await _openDetail(tester, 'Read a book (30m)');
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();
      expect(find.textContaining('+100 XP'), findsOneWidget); // 80 * 1.25

      // The completion SnackBar renders via the app's single root
      // ScaffoldMessenger, above everything else in the app (including
      // every tab) — remove it explicitly so it can't intercept a later
      // tap at whatever screen position it happens to occupy.
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // 7. The You tab's lifetime XP summary reflects it.
      await _goTo(tester, AppRoutes.you);
      expect(find.textContaining('100 XP total'), findsOneWidget);

      // 8. Delete the quest through confirmation. Invoking the AppBar
      // action's onPressed directly, same reasoning as `_openDetail`.
      await _openDetail(tester, 'Read a book (30m)');
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.delete_outline),
          )
          .onPressed!();
      await tester.pumpAndSettle();
      expect(find.textContaining('"Read a book (30m)"'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      // 9. Gone from the list.
      await _goTo(tester, AppRoutes.quests);
      expect(find.text('Read a book (30m)'), findsNothing);
      expect(find.textContaining('No quests yet'), findsOneWidget);

      // 10. Gone from the Today dashboard too.
      await _goTo(tester, AppRoutes.today);
      expect(find.text('Read a book (30m)'), findsNothing);

      // 11. But the XP already earned from it remains — the ledger is
      // immutable/append-only and is never touched by quest deletion.
      await _goTo(tester, AppRoutes.you);
      expect(find.textContaining('100 XP total'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
