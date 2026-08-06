import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/presentation/widgets/quest_card.dart';

import '../../../../support/test_localizations.dart';

final _today = DateTime.utc(2026, 1, 10);

Quest _buildQuest({
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
  String? visualKey,
}) {
  return Quest(
    id: 'q1',
    title: 'Workout',
    description: '',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: progressType,
    currentProgress: 0,
    targetProgress: targetProgress,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
    visualKey: visualKey,
  );
}

Widget _harness(Quest quest, QuestProgress? progress) {
  return MaterialApp(
    localizationsDelegates: testLocalizationsDelegates,
    supportedLocales: testSupportedLocales,
    home: Scaffold(
      body: QuestCard(quest: quest, todayProgress: progress, onTap: () {}),
    ),
  );
}

void main() {
  group('binary', () {
    testWidgets('shows nothing extra when not completed', (tester) async {
      await tester.pumpWidget(_harness(_buildQuest(), null));

      expect(find.text('Completed today'), findsNothing);
    });

    testWidgets('shows "Completed today" once complete', (tester) async {
      final progress = QuestProgress(
        questId: 'q1',
        date: _today,
        progressValue: 1,
        isComplete: true,
      );

      await tester.pumpWidget(_harness(_buildQuest(), progress));

      expect(find.text('Completed today'), findsOneWidget);
    });
  });

  group('quantity', () {
    testWidgets('shows current / target and a progress bar', (tester) async {
      final quest = _buildQuest(
        progressType: ProgressType.quantity,
        targetProgress: 8,
      );
      final progress = QuestProgress(
        questId: 'q1',
        date: _today,
        progressValue: 3,
        isComplete: false,
      );

      await tester.pumpWidget(_harness(quest, progress));

      expect(find.text('3 / 8'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows 0 / target when no progress exists yet', (tester) async {
      final quest = _buildQuest(
        progressType: ProgressType.quantity,
        targetProgress: 8,
      );

      await tester.pumpWidget(_harness(quest, null));

      expect(find.text('0 / 8'), findsOneWidget);
    });

    testWidgets('does not render any interaction controls', (tester) async {
      final quest = _buildQuest(
        progressType: ProgressType.quantity,
        targetProgress: 8,
      );

      await tester.pumpWidget(_harness(quest, null));

      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('duration', () {
    testWidgets('shows current / target in minutes', (tester) async {
      final quest = _buildQuest(
        progressType: ProgressType.duration,
        targetProgress: 30,
      );
      final progress = QuestProgress(
        questId: 'q1',
        date: _today,
        progressValue: 15,
        isComplete: false,
      );

      await tester.pumpWidget(_harness(quest, progress));

      expect(find.text('15 min / 30 min'), findsOneWidget);
    });
  });

  testWidgets('a long title truncates instead of overflowing', (tester) async {
    final quest = Quest(
      id: 'q1',
      title: 'A' * 200,
      description: '',
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

    await tester.pumpWidget(_harness(quest, null));

    expect(tester.takeException(), isNull);
  });

  group('Phase 17.2 visual continuity', () {
    testWidgets(
      'a quest created from a suggestion renders the matching bundled '
      'asset instead of the gradient placeholder',
      (tester) async {
        final quest = _buildQuest(visualKey: 'fitness/walk_20');

        await tester.pumpWidget(_harness(quest, null));
        await tester.pumpAndSettle();

        // find.byType(DecoratedBox) isn't a useful signal here — the
        // card's difficulty/XP chips are also Containers with a
        // BoxDecoration, which compile to DecoratedBox too; Image
        // presence/asset name is the actual distinguishing check.
        final image = tester.widget<Image>(find.byType(Image));
        expect(
          (image.image as AssetImage).assetName,
          'assets/visuals/walking.png',
        );
      },
    );

    testWidgets(
      'a hand-typed quest (no visualKey) still falls back to the gradient '
      'placeholder, exactly as before Phase 17.2',
      (tester) async {
        final quest = _buildQuest(); // visualKey: null

        await tester.pumpWidget(_harness(quest, null));
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNothing);
      },
    );
  });
}
