import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/today/presentation/today_page.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/player_level_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../../../support/fake_repositories.dart';
import '../../../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  required String id,
  required String title,
  QuestCompletionState state = QuestCompletionState.notStarted,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: state,
    failureBehavior: FailureBehavior.expire,
  );
}

Widget _harness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const TodayPage()),
      GoRoute(
        path: '/quests/:questId',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Text('detail:${state.pathParameters['questId']}'),
          ),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router),
  );
}

/// The dashboard has more content than the default test surface (800x600),
/// and `ListView` virtualizes children outside the viewport — without this,
/// sections below the fold (e.g. Today's XP Summary) are never mounted, so
/// `find.text` cannot locate them no matter how long `pumpAndSettle` runs.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('shows loading indicators before providers resolve', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('renders a coherent empty state with no quests and no XP', (
    tester,
  ) async {
    final overrides = fakeProviderOverrides(
      questRepository: FakeQuestRepository(),
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.textContaining('0 XP total'), findsOneWidget);
    expect(
      find.textContaining(
        'No quests yet. Quests you create will show up here.',
      ),
      findsWidgets, // both the Main Quest card and the quest list show this
    );
    expect(find.text('No XP earned today'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders player level, featured quest, and today\'s XP', (
    tester,
  ) async {
    _growViewport(tester);
    final questRepository = FakeQuestRepository()
      ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout')
      ..quests['q2'] = _buildQuest(id: 'q2', title: 'Read');
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
      questRepository: questRepository,
      questProgressRepository: progressRepository,
      xpLedgerRepository: ledgerRepository,
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    // Player header: 75 total XP, still Level 1.
    expect(find.text('Level 1'), findsOneWidget);
    expect(find.textContaining('75 XP total'), findsOneWidget);

    // Daily progress: 1 of 2 quests completed today.
    expect(find.textContaining('1 of 2 quests completed'), findsOneWidget);

    // Featured quest: q1 already complete today, so q2 ("Read") is featured —
    // it renders both in the Main Quest card and the Daily Quest List.
    expect(find.text('Read'), findsWidgets);

    // The quest list shows both quests, one marked complete.
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('Completed today'), findsOneWidget);

    // Today's XP summary.
    expect(find.text('75 XP'), findsWidgets); // headline + attribute tile
    expect(find.text('Health'), findsWidgets); // quest chips + attribute tile

    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the featured quest navigates to its detail route', (
    tester,
  ) async {
    final questRepository = FakeQuestRepository()
      ..quests['q1'] = _buildQuest(id: 'q1', title: 'Workout');
    final overrides = fakeProviderOverrides(
      questRepository: questRepository,
      questProgressRepository: FakeQuestProgressRepository(),
      xpLedgerRepository: FakeXpLedgerRepository(),
      today: _today,
    );

    await tester.pumpWidget(_harness(overrides));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Workout').first);
    await tester.pumpAndSettle();

    expect(find.text('detail:q1'), findsOneWidget);
  });

  testWidgets(
    'a section provider failure shows a friendly message, not a crash',
    (tester) async {
      final overrides = [
        ...fakeProviderOverrides(
          questRepository: FakeQuestRepository(),
          questProgressRepository: FakeQuestProgressRepository(),
          xpLedgerRepository: FakeXpLedgerRepository(),
          today: _today,
        ),
        playerLevelSummaryProvider.overrideWith(
          (ref) => Future.error(Exception('ledger unavailable')),
        ),
      ];

      await tester.pumpWidget(_harness(overrides));
      await tester.pumpAndSettle();

      expect(find.textContaining("Couldn't load your level"), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
