import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/data/mappers/quest_mapper.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/domain/entities/reward.dart';

void main() {
  const mapper = QuestMapper();

  Quest fullQuest() {
    return Quest(
      id: 'q1',
      title: 'Workout',
      description: 'Go to the gym',
      type: QuestType.mainStory,
      difficulty: QuestDifficulty.hard,
      attributeXpWeights: const {
        AttributeType.health: 70,
        AttributeType.strength: 40,
        AttributeType.discipline: 25,
      },
      linkedIdentityStatementIds: const ['stmt-1', 'stmt-2'],
      progressType: ProgressType.duration,
      currentProgress: 12.5,
      targetProgress: 60,
      deadline: DateTime.utc(2026, 3, 1, 12, 30),
      questChainId: 'chain-1',
      prerequisiteQuestIds: const ['q0'],
      state: QuestCompletionState.inProgress,
      failureBehavior: FailureBehavior.convertToRecovery,
      optionalReward: const Reward(
        xp: 500,
        titleId: 'title-1',
        achievementId: 'ach-1',
      ),
      repeatability: Repeatability.daily,
    );
  }

  test('round-trips every currently persisted field', () {
    final quest = fullQuest();
    final roundTripped = mapper.toDomain(mapper.toModel(quest));
    expect(roundTripped, quest);
  });

  test('round-trips when every nullable field is null', () {
    final quest = Quest(
      id: 'q2',
      title: 'Read',
      description: 'Read a book',
      type: QuestType.daily,
      difficulty: QuestDifficulty.trivial,
      attributeXpWeights: const {AttributeType.knowledge: 30},
      linkedIdentityStatementIds: const [],
      progressType: ProgressType.binary,
      currentProgress: 0,
      targetProgress: 1,
      prerequisiteQuestIds: const [],
      state: QuestCompletionState.notStarted,
      failureBehavior: FailureBehavior.expire,
    );

    final roundTripped = mapper.toDomain(mapper.toModel(quest));
    expect(roundTripped, quest);
    expect(roundTripped.deadline, isNull);
    expect(roundTripped.questChainId, isNull);
    expect(roundTripped.optionalReward, isNull);
    expect(roundTripped.repeatability, Repeatability.none);
  });

  test('weekly repeatability round-trips through the string field', () {
    final quest = fullQuest().copyWith(repeatability: Repeatability.weekly);
    final model = mapper.toModel(quest);
    expect(model.repeatabilityRule, 'weekly');
    expect(mapper.toDomain(model).repeatability, Repeatability.weekly);
  });

  test('legacy/unrecognized persisted repeatabilityRule strings fall back to '
      'Repeatability.none rather than throwing', () {
    final model = QuestHiveModel(
      id: 'legacy',
      title: 'Legacy quest',
      description: '',
      type: QuestType.daily.name,
      difficulty: QuestDifficulty.normal.name,
      attributeXpWeights: const {'health': 20},
      linkedIdentityStatementIds: const [],
      progressType: ProgressType.binary.name,
      currentProgress: 0,
      targetProgress: 1,
      prerequisiteQuestIds: const [],
      state: QuestCompletionState.notStarted.name,
      failureBehavior: FailureBehavior.expire.name,
      repeatabilityRule: 'monthly', // never produced by this app anymore
    );

    expect(mapper.toDomain(model).repeatability, Repeatability.none);
  });

  test('distinguishes a present-but-empty Reward from no Reward at all', () {
    final quest = fullQuest().copyWith(optionalReward: const Reward());
    final roundTripped = mapper.toDomain(mapper.toModel(quest));
    expect(roundTripped.optionalReward, isNotNull);
    expect(roundTripped.optionalReward, const Reward());
  });

  test('enum fields survive the round trip', () {
    final quest = fullQuest();
    final roundTripped = mapper.toDomain(mapper.toModel(quest));
    expect(roundTripped.type, quest.type);
    expect(roundTripped.difficulty, quest.difficulty);
    expect(roundTripped.progressType, quest.progressType);
    expect(roundTripped.state, quest.state);
    expect(roundTripped.failureBehavior, quest.failureBehavior);
  });

  test('attributeXpWeights keys survive as the correct AttributeType', () {
    final quest = fullQuest();
    final roundTripped = mapper.toDomain(mapper.toModel(quest));
    expect(roundTripped.attributeXpWeights, quest.attributeXpWeights);
  });
}
