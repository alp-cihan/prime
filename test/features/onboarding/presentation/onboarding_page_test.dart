import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/onboarding/presentation/onboarding_page.dart';
import 'package:prime/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/test_localizations.dart';

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('today-placeholder'))),
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

Future<void> _goToLastPage(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shows the first slide with Skip visible', (tester) async {
    await tester.pumpWidget(
      _harness([
        questRepositoryProvider.overrideWithValue(FakeQuestRepository()),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboardingRepository(completed: false),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Prime'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Back'), findsNothing);
  });

  testWidgets('Next advances slides and Back returns to the previous one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness([
        questRepositoryProvider.overrideWithValue(FakeQuestRepository()),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboardingRepository(completed: false),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Quests are the things you do'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Prime'), findsOneWidget);
  });

  testWidgets(
    'the final page offers starter templates and a Get Started action',
    (tester) async {
      await tester.pumpWidget(
        _harness([
          questRepositoryProvider.overrideWithValue(FakeQuestRepository()),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(completed: false),
          ),
        ]),
      );
      await tester.pumpAndSettle();

      await _goToLastPage(tester);

      expect(find.text('Want a head start?'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('Complete a workout'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Get Started'), findsOneWidget);
    },
  );

  testWidgets(
    'Skip immediately finishes onboarding without creating any quests',
    (tester) async {
      final questRepository = FakeQuestRepository();
      final onboardingRepository = FakeOnboardingRepository(completed: false);

      await tester.pumpWidget(
        _harness([
          questRepositoryProvider.overrideWithValue(questRepository),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        ]),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Skip'));
      await tester.pumpAndSettle();

      expect(find.text('today-placeholder'), findsOneWidget);
      expect(questRepository.quests, isEmpty);
      expect(onboardingRepository.isCompleted(), isTrue);
    },
  );

  testWidgets(
    'selecting templates and tapping "Add Selected & Get Started" creates '
    'exactly those quests through the normal quest application layer',
    (tester) async {
      final questRepository = FakeQuestRepository();
      final onboardingRepository = FakeOnboardingRepository(completed: false);

      await tester.pumpWidget(
        _harness([
          questRepositoryProvider.overrideWithValue(questRepository),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
        ]),
      );
      await tester.pumpAndSettle();

      await _goToLastPage(tester);
      await tester.tap(find.text('Drink water'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Add Selected & Get Started'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Add Selected & Get Started'),
      );
      await tester.pumpAndSettle();

      expect(find.text('today-placeholder'), findsOneWidget);
      expect(questRepository.quests.length, 1);
      expect(questRepository.quests.values.single.title, 'Drink water');
      expect(onboardingRepository.isCompleted(), isTrue);
    },
  );

  testWidgets('a double-tap on Get Started does not create duplicate quests', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository();

    await tester.pumpWidget(
      _harness([
        questRepositoryProvider.overrideWithValue(questRepository),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboardingRepository(completed: false),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    await _goToLastPage(tester);
    await tester.tap(find.text('Drink water'));
    await tester.pumpAndSettle();

    final gate = Completer<void>();
    questRepository.upsertGate = gate;

    await tester.tap(
      find.widgetWithText(FilledButton, 'Add Selected & Get Started'),
    );
    await tester.pump(); // loading state now showing, button disabled
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    await tester.pump();

    gate.complete();
    await tester.pumpAndSettle();

    expect(questRepository.quests.length, 1);
  });
}
