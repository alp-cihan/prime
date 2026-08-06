import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/pages/quest_form_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../../support/fake_repositories.dart';
import '../../../../support/test_localizations.dart';
import '../../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

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

Widget _harness(List<Override> overrides, {String? questId}) {
  final router = GoRouter(
    initialLocation: questId == null ? '/quests/new' : '/quests/q1/edit',
    routes: [
      GoRoute(
        path: '/quests',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('quest-list'))),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const QuestFormPage(),
          ),
          GoRoute(
            path: ':questId',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text('detail:${state.pathParameters['questId']}'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    QuestFormPage(questId: state.pathParameters['questId']),
              ),
            ],
          ),
        ],
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

/// The form has more content than the default test surface (800x600), and
/// it's laid out inside a `SingleChildScrollView` — without this, the
/// submit button can end up below the fold and untappable no matter how
/// long `pumpAndSettle` runs.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _enterTitle(WidgetTester tester, String title) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Title'), title);
}

Future<void> _enterWeight(WidgetTester tester, String weight) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'XP weight'),
    weight,
  );
}

void main() {
  group('create form', () {
    testWidgets('renders the expected fields', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Description'), findsOneWidget);
      expect(find.text('Quest type'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
      expect(find.text('Progress type'), findsOneWidget);
      expect(find.text('Attribute allocation'), findsOneWidget);
      expect(find.text('Repeats'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create Quest'), findsOneWidget);
    });

    testWidgets('shows a field-level error for an empty title', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(find.text('Title is required'), findsOneWidget);
      expect(find.text('quest-list'), findsNothing); // did not navigate
    });

    testWidgets('an invalid form does not submit (no quest created)', (
      tester,
    ) async {
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(questRepository.quests, isEmpty);
    });

    testWidgets('a valid form submits and navigates to the created quest', (
      tester,
    ) async {
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await _enterTitle(tester, 'Morning Run');
      await _enterWeight(tester, '50');
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(questRepository.quests.length, 1);
      final created = questRepository.quests.values.single;
      expect(created.title, 'Morning Run');
      expect(find.text('detail:${created.id}'), findsOneWidget);
    });

    testWidgets('the submit button disables while submitting', (tester) async {
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();
      await _enterTitle(tester, 'Morning Run');
      await _enterWeight(tester, '50');

      final gate = Completer<void>();
      questRepository.upsertGate = gate;

      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pump(); // one frame: loading, use case suspended on gate

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a domain-level validation failure shows a readable error', (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      // Passes local Form validation (weight is a valid non-negative
      // integer: 0) but fails QuestInputValidator's "at least one
      // allocation must be greater than zero" domain rule.
      await _enterTitle(tester, 'Morning Run');
      await _enterWeight(tester, '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pumpAndSettle();

      expect(find.textContaining('greater than zero'), findsOneWidget);
      expect(find.text('quest-list'), findsNothing);
    });

    testWidgets('duplicate taps create only one quest', (tester) async {
      final questRepository = FakeQuestRepository();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();
      await _enterTitle(tester, 'Morning Run');
      await _enterWeight(tester, '50');

      // Gate the repository write so the first tap's submission is
      // provably still in flight (not just fast) when the second tap
      // lands — the button is disabled by then (one frame after the
      // first tap), so the second tap cannot trigger another submission.
      final gate = Completer<void>();
      questRepository.upsertGate = gate;

      await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
      await tester.pump(); // loading state now showing, button disabled
      // The button's label is now a spinner, not the text — find it by
      // type instead.
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      gate.complete();
      await tester.pumpAndSettle();

      expect(questRepository.quests.length, 1);
    });
  });

  group('edit form', () {
    testWidgets('loads and prefills the quest', (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides, questId: 'q1'));
      await tester.pumpAndSettle();

      final titleField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Title'),
      );
      expect(titleField.controller!.text, 'Workout');
      expect(find.widgetWithText(FilledButton, 'Save Changes'), findsOneWidget);
    });

    testWidgets('a missing quest id shows a not-found state', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides, questId: 'q1'));
      await tester.pumpAndSettle();

      expect(find.textContaining("doesn't exist"), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Save Changes'), findsNothing);
    });

    testWidgets('a valid edit submits and returns to the detail screen', (
      tester,
    ) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides, questId: 'q1'));
      await tester.pumpAndSettle();

      await _enterTitle(tester, 'Renamed Workout');
      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(questRepository.quests['q1']!.title, 'Renamed Workout');
      expect(find.text('detail:q1'), findsOneWidget);
    });

    testWidgets('a failed edit allows retry without losing entered data', (
      tester,
    ) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides, questId: 'q1'));
      await tester.pumpAndSettle();

      await _enterTitle(tester, 'Renamed Workout');
      await _enterWeight(tester, '0'); // triggers the domain-level failure
      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.textContaining('greater than zero'), findsOneWidget);
      expect(find.text('detail:q1'), findsNothing); // stayed on the form

      await _enterWeight(tester, '80'); // fix it
      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(questRepository.quests['q1']!.title, 'Renamed Workout');
      expect(find.text('detail:q1'), findsOneWidget);
    });
  });

  group('unsaved changes', () {
    testWidgets(
      'an untouched create form has nothing to confirm on back navigation',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        _growViewport(tester);
        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('quest-list'), findsOneWidget);
        expect(find.text('Discard changes?'), findsNothing);
      },
    );

    testWidgets(
      'a dirty create form confirms before discarding, and "Keep Editing" '
      'preserves the entered title',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        _growViewport(tester);
        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        await _enterTitle(tester, 'Half-written quest');
        await tester.pump();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsOneWidget);
        expect(find.text('quest-list'), findsNothing); // still on the form

        await tester.tap(find.widgetWithText(TextButton, 'Keep Editing'));
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsNothing);
        expect(
          tester
              .widget<TextFormField>(
                find.widgetWithText(TextFormField, 'Title'),
              )
              .controller!
              .text,
          'Half-written quest', // preserved, not cleared
        );
      },
    );

    testWidgets('confirming "Discard" on a dirty create form navigates away', (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      _growViewport(tester);
      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await _enterTitle(tester, 'Half-written quest');
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Discard'));
      await tester.pumpAndSettle();

      expect(find.text('quest-list'), findsOneWidget);
    });

    testWidgets(
      'an edit form with no changes has nothing to confirm on back navigation',
      (tester) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest();
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        _growViewport(tester);
        await tester.pumpWidget(_harness(overrides, questId: 'q1'));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('detail:q1'), findsOneWidget);
        expect(find.text('Discard changes?'), findsNothing);
      },
    );

    testWidgets(
      'editing a field on the edit form requires confirmation to leave',
      (tester) async {
        final questRepository = FakeQuestRepository()
          ..quests['q1'] = _buildQuest();
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        _growViewport(tester);
        await tester.pumpWidget(_harness(overrides, questId: 'q1'));
        await tester.pumpAndSettle();

        await _enterTitle(tester, 'Workout (renamed)');
        await tester.pump();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsOneWidget);
        expect(find.text('detail:q1'), findsNothing);
      },
    );

    testWidgets(
      'a successful submit navigates away without an unsaved-changes prompt',
      (tester) async {
        final questRepository = FakeQuestRepository();
        final overrides = fakeProviderOverrides(
          questRepository: questRepository,
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        _growViewport(tester);
        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        await _enterTitle(tester, 'Morning Run');
        await _enterWeight(tester, '50');
        await tester.tap(find.widgetWithText(FilledButton, 'Create Quest'));
        await tester.pumpAndSettle();

        expect(find.text('Discard changes?'), findsNothing);
        expect(questRepository.quests.length, 1);
      },
    );
  });
}
