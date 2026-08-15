import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/suggestions/presentation/suggestion_detail_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';
import '../../../support/widget_test_harness.dart';

/// Phase 17.3.1 — fixes `CreateQuestFromSuggestionUseCase` persisting the
/// suggestion catalog's raw English `title`/`description` regardless of the
/// UI language the user actually saw and tapped "Add" on. These tests pin
/// the fix at the widget boundary: `SuggestionDetailPage` resolves the
/// currently-displayed (locale-aware) text via `suggestion_localization.dart`
/// and passes it through `SuggestionCreationController.create` into the use
/// case — never `AppLocalizations` reaching the pure-Dart use case itself.
///
/// `study_pomodoro` is used throughout — its known EN/TR catalog text:
///   EN title: "Study one focused Pomodoro"
///   EN desc:  "25 minutes of distraction-free study, one clean block."
///   TR title: "Odaklanmış bir Pomodoro çalış"
///   TR desc:  "Dikkat dağıtmadan 25 dakika, tek bir temiz blok."
const _enTitle = 'Study one focused Pomodoro';
const _enDescription = '25 minutes of distraction-free study, one clean block.';
const _trTitle = 'Odaklanmış bir Pomodoro çalış';
const _trDescription = 'Dikkat dağıtmadan 25 dakika, tek bir temiz blok.';

Widget _harness(
  List<Override> overrides, {
  String suggestionId = 'study_pomodoro',
  Locale? locale,
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
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: testLocalizationsDelegates,
      supportedLocales: testSupportedLocales,
    ),
  );
}

/// Same reasoning as `suggestion_detail_page_test.dart`'s identically-named
/// helper — the detail page builds every child eagerly, so `tap()` needs it
/// on-screen without scrolling.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets(
    'creating a quest while the UI is in Turkish persists the Turkish '
    'title and description, not the English catalog source',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      await tester.pumpWidget(_harness(overrides, locale: const Locale('tr')));
      await tester.pumpAndSettle();

      expect(find.text(_trTitle), findsWidgets); // AppBar + body
      await tester.tap(find.widgetWithText(FilledButton, 'Görevlerime Ekle'));
      await tester.pumpAndSettle();

      expect(questRepository.quests.length, 1);
      final quest = questRepository.quests.values.single;
      expect(quest.title, _trTitle);
      expect(quest.description, _trDescription);
    },
  );

  testWidgets(
    'creating a quest while the UI is in English persists the English '
    'title and description',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      await tester.pumpWidget(_harness(overrides, locale: const Locale('en')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Add to My Quests'));
      await tester.pumpAndSettle();

      expect(questRepository.quests.length, 1);
      final quest = questRepository.quests.values.single;
      expect(quest.title, _enTitle);
      expect(quest.description, _enDescription);
    },
  );

  testWidgets('switching the app language after creation does not alter the '
      'already-persisted quest', (tester) async {
    _growViewport(tester);
    final questRepository = FakeQuestRepository();
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    // Create while Turkish.
    await tester.pumpWidget(_harness(overrides, locale: const Locale('tr')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Görevlerime Ekle'));
    await tester.pumpAndSettle();

    expect(questRepository.quests.length, 1);
    final createdId = questRepository.quests.keys.single;
    expect(questRepository.quests[createdId]!.title, _trTitle);

    // Simulate a later language switch to English — same underlying data
    // (same `questRepository`/`overrides`), fresh widget tree.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_harness(overrides, locale: const Locale('en')));
    await tester.pumpAndSettle();

    // The persisted quest is untouched: still one record, still the
    // Turkish text it was created with, regardless of the UI's language.
    expect(questRepository.quests.length, 1);
    expect(questRepository.quests[createdId]!.title, _trTitle);
    expect(questRepository.quests[createdId]!.description, _trDescription);
  });

  testWidgets(
    'duplicate prevention still works against a localized (Turkish) title',
    (tester) async {
      _growViewport(tester);
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
      );

      await tester.pumpWidget(_harness(overrides, locale: const Locale('tr')));
      await tester.pumpAndSettle();

      final addButton = find.widgetWithText(FilledButton, 'Görevlerime Ekle');
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      expect(questRepository.quests.length, 1);

      // Tap "Add" again on the very same (still-mounted) detail screen —
      // the button re-enables once creation settles, exactly like a second
      // visit to a suggestion already accepted in a previous session.
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(questRepository.quests.length, 1); // still just one
      expect(find.textContaining('zaten görevlerinizde'), findsOneWidget);
    },
  );
}
