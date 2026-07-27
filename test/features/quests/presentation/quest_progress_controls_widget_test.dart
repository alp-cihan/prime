import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/presentation/quest_detail_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  String id = 'q1',
  ProgressType progressType = ProgressType.quantity,
  double targetProgress = 8,
}) {
  return Quest(
    id: id,
    title: 'Drink water',
    description: 'Stay hydrated',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 40},
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/quests/q1',
    routes: [
      GoRoute(
        path: '/quests',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('quest-list'))),
        routes: [
          GoRoute(
            path: ':questId',
            builder: (context, state) =>
                QuestDetailPage(questId: state.pathParameters['questId']!),
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

void main() {
  group('quantity quest controls', () {
    testWidgets('renders current/target and a progress bar', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.text('0 / 8'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.byTooltip('Increase by 1'), findsOneWidget);
      expect(find.byTooltip('Decrease by 1'), findsOneWidget);
    });

    testWidgets('the minus button is disabled at zero', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      final minusButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Decrease by 1'),
          matching: find.byType(IconButton),
        ),
      );
      expect(minusButton.onPressed, isNull);
    });

    testWidgets('tapping plus increments progress', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Increase by 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 8'), findsOneWidget);
    });

    testWidgets('the plus button is disabled once at target', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(targetProgress: 1),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Increase by 1'));
      await tester.pumpAndSettle();

      expect(find.text('1 / 1'), findsOneWidget);
      final plusButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip('Increase by 1'),
          matching: find.byType(IconButton),
        ),
      );
      expect(plusButton.onPressed, isNull);
    });

    testWidgets(
      'shows completion feedback exactly once when target is reached',
      (tester) async {
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()
            ..quests['q1'] = _buildQuest(targetProgress: 1),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Increase by 1'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Quest completed'), findsOneWidget);
      },
    );

    testWidgets(
      'disables controls and shows a spinner while a mutation is in flight',
      (tester) async {
        final progressRepository = FakeQuestProgressRepository();
        final overrides = fakeProviderOverrides(
          questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
          questProgressRepository: progressRepository,
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        );

        await tester.pumpWidget(_harness(overrides));
        await tester.pumpAndSettle();

        final gate = Completer<void>();
        progressRepository.upsertGate = gate;

        await tester.tap(find.byTooltip('Increase by 1'));
        await tester.pump(); // one frame: loading, use case suspended on gate

        expect(find.byType(CircularProgressIndicator), findsWidgets);
        final plusButton = tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip('Increase by 1'),
            matching: find.byType(IconButton),
          ),
        );
        expect(plusButton.onPressed, isNull);

        gate.complete();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('renders without overflow on a narrow phone viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690); // a small phone
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(targetProgress: 8),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('duration quest controls', () {
    Quest buildDurationQuest() =>
        _buildQuest(progressType: ProgressType.duration, targetProgress: 30);

    testWidgets('renders current/target minutes and quick-add buttons', (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = buildDurationQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.text('0 / 30 min'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
      expect(find.text('10 min'), findsOneWidget);
      expect(find.text('15 min'), findsOneWidget);
      expect(find.text('-5 min'), findsOneWidget);
    });

    testWidgets('tapping +10 min adds ten minutes', (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = buildDurationQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10 min'));
      await tester.pumpAndSettle();

      expect(find.text('10 / 30 min'), findsOneWidget);
    });

    testWidgets('quick-add clamps to the target rather than overshooting', (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            progressType: ProgressType.duration,
            targetProgress: 10,
          ),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('15 min'));
      await tester.pumpAndSettle();

      expect(find.text('10 / 10 min'), findsOneWidget);
      expect(find.textContaining('Quest completed'), findsOneWidget);
    });

    testWidgets('-5 min decrements minutes', (tester) async {
      final progressRepository = FakeQuestProgressRepository();
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = buildDurationQuest(),
        questProgressRepository: progressRepository,
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('-5 min'));
      await tester.pumpAndSettle();

      expect(find.text('5 / 30 min'), findsOneWidget);
    });

    testWidgets('renders without overflow on a narrow phone viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 690);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = buildDurationQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('binary controls', () {
    testWidgets('shows the completed indicator once complete today', (
      tester,
    ) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(
            progressType: ProgressType.binary,
            targetProgress: 1,
          ),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.text('Complete Quest'), findsOneWidget);

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.text('Complete Quest'), findsNothing);
      expect(find.text('Quest complete for today'), findsOneWidget);
    });
  });
}
