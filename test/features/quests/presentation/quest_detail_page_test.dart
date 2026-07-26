import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/quest_detail_page.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  String id = 'q1',
  QuestCompletionState state = QuestCompletionState.notStarted,
}) {
  return Quest(
    id: id,
    title: 'Workout',
    description: 'Go to the gym',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {
      AttributeType.health: 60,
      AttributeType.strength: 40,
    },
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
  );
}

Widget _harness(String questId, List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/quests/$questId',
    routes: [
      GoRoute(
        path: '/quests/:questId',
        builder: (context, state) => QuestDetailPage(questId: questId),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('shows a loading indicator before questByIdProvider resolves', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a not-found state for a missing quest id', (tester) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('missing', overrides));
    await tester.pumpAndSettle();

    expect(find.textContaining("doesn't exist"), findsOneWidget);
  });

  testWidgets('renders quest data: title, description, difficulty, base XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    expect(find.text('Workout'), findsOneWidget); // AppBar title
    expect(find.text('Go to the gym'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.textContaining('100 XP'), findsWidgets); // 60 + 40
  });

  testWidgets("renders today's progress", (tester) async {
    // A real completion always writes progress + ledger rows together
    // (CompleteQuestUseCase), so a realistic fixture seeds both.
    final progressRepository = FakeQuestProgressRepository()
      ..entries.add(
        QuestProgress(
          questId: 'q1',
          date: _today,
          progressValue: 1,
          isComplete: true,
        ),
      );
    final ledgerRepository = FakeXpLedgerRepository()
      ..byKey['q1|health|2026-01-10|0'] = XpTransaction(
        id: 'x1',
        sourceType: XpSourceType.quest,
        sourceId: 'q1|2026-01-10|0',
        attribute: AttributeType.health,
        baseXp: 60,
        modifiersApplied: const {},
        finalXp: 75,
        createdAt: _today,
        idempotencyKey: 'q1|health|2026-01-10|0',
      );
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: progressRepository,
      xpLedgerRepository: ledgerRepository,
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    expect(find.text('1 time'), findsOneWidget);
  });

  testWidgets("renders today's XP earned for this quest", (tester) async {
    final ledgerRepository = FakeXpLedgerRepository()
      ..byKey['q1|health|2026-01-10|0'] = XpTransaction(
        id: 'x1',
        sourceType: XpSourceType.quest,
        sourceId: 'q1|2026-01-10|0',
        attribute: AttributeType.health,
        baseXp: 60,
        modifiersApplied: const {},
        finalXp: 75,
        createdAt: _today,
        idempotencyKey: 'q1|health|2026-01-10|0',
      );
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: ledgerRepository,
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    expect(find.text('75 XP'), findsOneWidget);
  });

  testWidgets(
    'tapping Complete triggers the controller and disables the button while loading',
    (tester) async {
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest();
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester
          .pumpAndSettle(); // initial load already resolved questByIdProvider's own getById call

      // Gate CompleteQuestUseCase's first repository call so the completion
      // pipeline provably suspends mid-flight, instead of racing a fake that
      // would otherwise resolve within the same microtask flush as pump().
      final gate = Completer<void>();
      questRepository.getByIdGate = gate;

      await tester.tap(find.text('Complete Quest'));
      await tester
          .pump(); // one frame: loading state, use case suspended on the gate

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull); // disabled while loading
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      gate.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('success shows a confirmation with the awarded XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness('q1', overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Complete Quest'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('+125 XP'),
      findsOneWidget,
    ); // round(100) * 1.25 first-completion bonus
  });

  testWidgets(
    "provider-backed progress and XP update after success, without manual refresh",
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = _buildQuest(),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      expect(find.text('Not yet'), findsOneWidget);

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.text('Not yet'), findsNothing);
      expect(find.text('1 time'), findsOneWidget);
      expect(find.text('125 XP'), findsOneWidget);
    },
  );

  testWidgets(
    'a completion failure displays a readable error and allows retry',
    (tester) async {
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()
          ..quests['q1'] = _buildQuest(state: QuestCompletionState.expired),
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
      );

      await tester.pumpWidget(_harness('q1', overrides));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't complete this quest"), findsOneWidget);
      expect(find.textContaining('cannot be completed'), findsOneWidget);

      // Retry stays available and re-attempts through the same controller.
      final retryButton = find.widgetWithText(OutlinedButton, 'Retry');
      expect(retryButton, findsOneWidget);
      await tester.ensureVisible(
        retryButton,
      ); // may be below the fold in the SingleChildScrollView
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't complete this quest"), findsOneWidget);
    },
  );
}
