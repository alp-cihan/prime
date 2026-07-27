import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/app.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/presentation/widgets/achievement_unlock_dialog.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  required String id,
  required String title,
  QuestDifficulty difficulty = QuestDifficulty.normal,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: difficulty,
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

void main() {
  testWidgets(
    'no dialog on boot; completing a quest that unlocks two achievements at '
    'once shows one dialog at a time, each exactly once',
    (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final questRepository = FakeQuestRepository()
        // A Very Hard completion unlocks both "First Step" (1st completion
        // ever) and "Challenger" (a Hard-or-above completion) in one pass.
        ..quests['q1'] = _buildQuest(
          id: 'q1',
          title: 'Boss Workout',
          difficulty: QuestDifficulty.veryHard,
        );
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: FakeXpLedgerRepository(),
        today: _today,
        // Deliberately NOT allUnlocked() — this test is specifically about
        // achievements unlocking and their dialogs.
      );

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      // 1. No dialog merely from booting with an empty ledger.
      expect(find.byType(AchievementUnlockDialog), findsNothing);

      // 2. Complete the quest -> two achievements unlock at once.
      await tester.tap(find.byIcon(Icons.checklist_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Boss Workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      // First dialog: exactly one shown, for exactly one achievement.
      expect(find.byType(AchievementUnlockDialog), findsOneWidget);
      expect(find.text('ACHIEVEMENT UNLOCKED'), findsOneWidget);
      final firstTitleFinder = find.descendant(
        of: find.byType(AchievementUnlockDialog),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text && (w.data == 'First Step' || w.data == 'Challenger'),
        ),
      );
      expect(firstTitleFinder, findsOneWidget);
      final firstTitle = tester.widget<Text>(firstTitleFinder).data;

      // Dismiss the first — the second, distinct achievement's dialog
      // appears next (never both at once, never the same one twice).
      // Direct invocation instead of `tester.tap` — this dialog's "Nice"
      // button hits the same accumulated-overlay hit-test flakiness
      // documented elsewhere in this suite (see
      // `quest_progress_full_flow_test.dart`'s `_tapFab` etc.).
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Nice'))
          .onPressed!();
      await tester.pumpAndSettle();

      expect(find.byType(AchievementUnlockDialog), findsOneWidget);
      final secondTitleFinder = find.descendant(
        of: find.byType(AchievementUnlockDialog),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text && (w.data == 'First Step' || w.data == 'Challenger'),
        ),
      );
      final secondTitle = tester.widget<Text>(secondTitleFinder).data;
      expect(secondTitle, isNot(firstTitle));

      // Dismiss the second — no more dialogs.
      // Direct invocation instead of `tester.tap` — this dialog's "Nice"
      // button hits the same accumulated-overlay hit-test flakiness
      // documented elsewhere in this suite (see
      // `quest_progress_full_flow_test.dart`'s `_tapFab` etc.).
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Nice'))
          .onPressed!();
      await tester.pumpAndSettle();
      expect(find.byType(AchievementUnlockDialog), findsNothing);

      // 3. No duplicate dialog on further rebuilds/tab navigation.
      await tester.tap(find.byIcon(Icons.auto_stories_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.today_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(AchievementUnlockDialog), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
}
