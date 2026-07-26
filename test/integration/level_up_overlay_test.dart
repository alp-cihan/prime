import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/app.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/widgets/level_up_dialog.dart';

import '../support/fake_repositories.dart';
import '../support/widget_test_harness.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  required String id,
  required String title,
  required Map<AttributeType, int> weights,
  QuestDifficulty difficulty = QuestDifficulty.normal,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: difficulty,
    attributeXpWeights: weights,
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
    'no overlay on initial stored XP, one overlay per level-crossing completion, '
    'no duplicate on rebuild/tab navigation, and a later level-up shows again',
    (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Seed 150 lifetime XP (already Level 2 — architecture.md §4.1: level 2
      // starts at cumulative 100) *before* boot, so the very first
      // `totalXpProvider` observation the app ever makes is already above
      // Level 1 — exactly the case the initial-load rule must not fire on.
      final ledgerRepository = FakeXpLedgerRepository()
        ..byKey['seed|health|2026-01-01|0'] = XpTransaction(
          id: 'seed-1',
          sourceType: XpSourceType.quest,
          sourceId: 'seed|2026-01-01|0',
          attribute: AttributeType.health,
          baseXp: 150,
          modifiersApplied: const {},
          finalXp: 150,
          createdAt: DateTime.utc(2026, 1, 1),
          idempotencyKey: 'seed|health|2026-01-01|0',
        );
      // q1 pushes total from 150 to 525 (375 awarded), crossing Level 2's
      // upper bound (382) into Level 3.
      final questRepository = FakeQuestRepository()
        ..quests['q1'] = _buildQuest(
          id: 'q1',
          title: 'Cross Level 3',
          weights: const {AttributeType.health: 300},
        )
        // q2 pushes total from 525 to 1325 (800 awarded), crossing Level 3's
        // upper bound (902) into Level 4.
        ..quests['q2'] = _buildQuest(
          id: 'q2',
          title: 'Cross Level 4',
          weights: const {AttributeType.health: 400},
          difficulty: QuestDifficulty.veryHard,
        );
      final overrides = fakeProviderOverrides(
        questRepository: questRepository,
        questProgressRepository: FakeQuestProgressRepository(),
        xpLedgerRepository: ledgerRepository,
        today: _today,
      );

      await tester.pumpWidget(
        ProviderScope(overrides: overrides, child: const PrimeApp()),
      );
      await tester.pumpAndSettle();

      // 1. No overlay merely from booting with an already-elevated account.
      expect(find.byType(LevelUpDialog), findsNothing);

      // 2. Complete q1 -> crosses Level 2 into Level 3 -> exactly one overlay.
      await tester.tap(find.byIcon(Icons.checklist_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cross Level 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.byType(LevelUpDialog), findsOneWidget);
      expect(find.text('LEVEL UP'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LevelUpDialog),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );

      // 3. Dismiss acknowledges — the overlay closes and does not reopen on
      // further rebuilds (tab navigation).
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(LevelUpDialog), findsNothing);

      // Back to the quest list (each shell branch keeps its own stack — the
      // Quests tab would otherwise reopen on q1's detail page, not the list).
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.auto_stories_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.today_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(LevelUpDialog), findsNothing);

      // 4. A second, later level-up (Level 3 -> Level 4) still fires.
      await tester.tap(find.byIcon(Icons.checklist_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cross Level 4'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Quest'));
      await tester.pumpAndSettle();

      expect(find.byType(LevelUpDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(LevelUpDialog),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(LevelUpDialog), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
}
