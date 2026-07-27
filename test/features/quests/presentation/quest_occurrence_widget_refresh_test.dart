import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';
import 'package:prime/features/quests/presentation/quest_detail_page.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../support/fake_repositories.dart';

final _day1 = DateTime.utc(2026, 1, 10);
final _day2 = _day1.add(const Duration(days: 1));

Quest _buildDailyQuest() {
  return const Quest(
    id: 'q1',
    title: 'Workout',
    description: 'Go to the gym',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 60},
    linkedIdentityStatementIds: [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
    repeatability: Repeatability.daily,
  );
}

Widget _harness(ProviderContainer container) {
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
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets(
    'opening a daily quest again after a day has passed shows it eligible '
    'again automatically — no manual refresh, no reset action, just the '
    'occurrence anchor date provider resolving to a new day on its next read',
    (tester) async {
      final clock = FakeClock(_day1);
      final container = ProviderContainer(
        overrides: [
          questRepositoryProvider.overrideWithValue(
            FakeQuestRepository()..quests['q1'] = _buildDailyQuest(),
          ),
          questProgressRepositoryProvider.overrideWithValue(
            FakeQuestProgressRepository(),
          ),
          xpLedgerRepositoryProvider.overrideWithValue(
            FakeXpLedgerRepository(),
          ),
          clockProvider.overrideWithValue(clock),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_harness(container));
      await tester.pumpAndSettle();

      // Day 1: complete the quest.
      expect(find.text('Complete Quest'), findsOneWidget);
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();
      expect(find.text('Quest complete for today'), findsOneWidget);
      expect(find.text('Complete Quest'), findsNothing);

      // A day passes. Nothing in the app calls a "reset" use case, runs a
      // background job, or shows a notification — the occurrence anchor
      // date provider simply resolves to a new day the next time anything
      // reads it, which invalidating it here simulates (the same thing an
      // autoDispose provider naturally does when a screen is left and
      // reopened later, per this phase's "lazy reset" requirement).
      clock.advanceTo(_day2);
      container.invalidate(
        questOccurrenceAnchorDateProvider(Repeatability.daily),
      );
      await tester.pumpAndSettle();

      // Fresh occurrence: eligible again, progress reset (no completed
      // indicator), all without any manual reload gesture from the test.
      expect(find.text('Quest complete for today'), findsNothing);
      expect(find.text('Complete Quest'), findsOneWidget);
    },
  );
}
