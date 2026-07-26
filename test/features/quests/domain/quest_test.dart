import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/domain/entities/reward.dart';

Quest _buildQuest() {
  return const Quest(
    id: 'q1',
    title: 'Workout',
    description: 'Go to the gym',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 70, AttributeType.strength: 40},
    linkedIdentityStatementIds: [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void main() {
  group('Quest', () {
    test('supports value equality', () {
      expect(_buildQuest(), _buildQuest());
    });

    test('copyWith overrides only the given fields', () {
      final updated = _buildQuest().copyWith(
        state: QuestCompletionState.complete,
      );
      expect(updated.state, QuestCompletionState.complete);
      expect(updated.title, 'Workout');
    });
  });

  group('QuestProgress', () {
    test('supports value equality and copyWith', () {
      final date = DateTime(2026, 1, 1);
      final a = QuestProgress(
        questId: 'q1',
        date: date,
        progressValue: 1,
        isComplete: true,
      );
      final b = QuestProgress(
        questId: 'q1',
        date: date,
        progressValue: 1,
        isComplete: true,
      );
      expect(a, b);

      final withNotes = a.copyWith(notes: 'felt great');
      expect(withNotes.notes, 'felt great');
      expect(withNotes.isComplete, true);
    });
  });

  group('Reward', () {
    test('supports value equality and copyWith', () {
      const a = Reward(xp: 100);
      const b = Reward(xp: 100);
      expect(a, b);

      final withTitle = a.copyWith(titleId: 't1');
      expect(withTitle.titleId, 't1');
      expect(withTitle.xp, 100);
    });
  });
}
