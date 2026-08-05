import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/features/suggestions/domain/entities/recommendation_profile.dart';
import 'package:prime/features/suggestions/presentation/recommendation_profile_editor_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.push('/preferences'),
              child: const Text('behind'),
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'preferences',
            builder: (context, state) =>
                const RecommendationProfileEditorPage(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

/// Pumps the harness already on the preferences screen, reached through a
/// real `context.push` (not a pre-attach `router.push`, which leaves
/// go_router's internal stack unable to `pop()` back out).
Future<void> _pumpOnPreferences(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pumpAndSettle();
  await tester.tap(find.text('behind'));
  await tester.pumpAndSettle();
}

/// The editor is a `ListView` of chip sections — enough content that
/// "Save Preferences" and later chips fall outside the default 800x600
/// test surface and `ListView`'s sliver virtualization never builds them.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('preselects the current profile values', (tester) async {
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

    await _pumpOnPreferences(tester, overrides);

    final studentChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Student'),
    );
    expect(studentChip.selected, isTrue);
    final studyChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Study'),
    );
    expect(studyChip.selected, isTrue);
  });

  testWidgets('is a concise single screen — every input is a chip, no free '
      'text fields', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await _pumpOnPreferences(tester, overrides);

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('saving persists the edited profile and pops back', (
    tester,
  ) async {
    _growViewport(tester);
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
    );

    await _pumpOnPreferences(tester, overrides);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Retired'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Mindfulness'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Gentle'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save Preferences'));
    await tester.pumpAndSettle();

    expect(find.text('behind'), findsOneWidget); // popped back
    expect(find.text('Preferences saved'), findsOneWidget);
  });

  testWidgets('a saved edit is actually persisted through the repository', (
    tester,
  ) async {
    _growViewport(tester);
    final profileRepository = FakeRecommendationProfileRepository();
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: DateTime.utc(2026, 1, 10),
      recommendationProfileRepository: profileRepository,
    );

    await _pumpOnPreferences(tester, overrides);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Entrepreneur'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save Preferences'));
    await tester.pumpAndSettle();

    final saved = await profileRepository.get();
    expect(saved.lifeStage, LifeStage.entrepreneur);
    expect(saved.isPersonalized, isTrue);
  });
}
