import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/app.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

/// The You tab now has more content than the default test surface
/// (800x600) — enlarging the viewport keeps the attribute breakdown
/// reachable by `find.text` without needing manual scrolling.
void _growViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets(
    'boot the app, display a quest, navigate to detail, complete it, and see XP/progress update',
    (tester) async {
      _growViewport(tester);

      final quest = Quest(
        id: 'q1',
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
        state: QuestCompletionState.notStarted,
        failureBehavior: FailureBehavior.expire,
      );
      final overrides = fakeProviderOverrides(
        questRepository: FakeQuestRepository()..quests['q1'] = quest,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: DateTime.utc(2026, 1, 10),
        // This test is about the completion flow, not achievements — see
        // `FakeAchievementUnlockRepository.allUnlocked`'s doc.
        achievementUnlockRepository:
            FakeAchievementUnlockRepository.allUnlocked(),
      );

      // Boot the real app.
      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      // Display the quest on the Quests tab.
      await tester.tap(find.byIcon(Icons.checklist_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Completed today'), findsNothing);

      // Navigate to detail.
      await tester.tap(find.text('Workout'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Workout'), findsOneWidget);
      expect(find.text('Not yet'), findsOneWidget);

      // Complete it through the real CompleteQuestController.
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      // Success confirmation with the awarded XP.
      expect(
        find.textContaining('+125 XP'),
        findsOneWidget,
      ); // round(100) * 1.25 first-completion bonus

      // Progress updates on the same screen, no manual refresh.
      expect(find.text('Not yet'), findsNothing);
      expect(find.text('1 time'), findsOneWidget);
      expect(find.text('125 XP'), findsOneWidget);

      // Back to the list — today's completion now shows there too.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Completed today'), findsOneWidget);

      // The You tab's global XP summary reflects it as well.
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.textContaining('125 XP total'), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('75 XP'), findsOneWidget); // 60 * 1.25
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('50 XP'), findsOneWidget); // 40 * 1.25

      expect(tester.takeException(), isNull);
    },
  );
}
