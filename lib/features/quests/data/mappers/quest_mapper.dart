import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/reward.dart';
import '../models/quest_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [Quest]. Enums are stored as
/// their `.name` string rather than via a generated Hive enum adapter —
/// resilient to the enum's declaration order changing, and avoids spending
/// a `typeId` per enum.
class QuestMapper {
  const QuestMapper();

  QuestHiveModel toModel(Quest quest) {
    final reward = quest.optionalReward;
    return QuestHiveModel(
      id: quest.id,
      title: quest.title,
      description: quest.description,
      type: quest.type.name,
      difficulty: quest.difficulty.name,
      attributeXpWeights: {
        for (final entry in quest.attributeXpWeights.entries)
          entry.key.name: entry.value,
      },
      linkedIdentityStatementIds: quest.linkedIdentityStatementIds,
      progressType: quest.progressType.name,
      currentProgress: quest.currentProgress,
      targetProgress: quest.targetProgress,
      deadlineUtcMicros: quest.deadline?.toUtc().microsecondsSinceEpoch,
      questChainId: quest.questChainId,
      prerequisiteQuestIds: quest.prerequisiteQuestIds,
      state: quest.state.name,
      failureBehavior: quest.failureBehavior.name,
      repeatabilityRule: quest.repeatabilityRule,
      rewardXp: reward?.xp,
      rewardTitleId: reward?.titleId,
      rewardAchievementId: reward?.achievementId,
      hasReward: reward != null,
    );
  }

  Quest toDomain(QuestHiveModel model) {
    return Quest(
      id: model.id,
      title: model.title,
      description: model.description,
      type: QuestType.values.byName(model.type),
      difficulty: QuestDifficulty.values.byName(model.difficulty),
      attributeXpWeights: {
        for (final entry in model.attributeXpWeights.entries)
          AttributeType.values.byName(entry.key): entry.value,
      },
      linkedIdentityStatementIds: List<String>.from(
        model.linkedIdentityStatementIds,
      ),
      progressType: ProgressType.values.byName(model.progressType),
      currentProgress: model.currentProgress,
      targetProgress: model.targetProgress,
      deadline: model.deadlineUtcMicros == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              model.deadlineUtcMicros!,
              isUtc: true,
            ),
      questChainId: model.questChainId,
      prerequisiteQuestIds: List<String>.from(model.prerequisiteQuestIds),
      state: QuestCompletionState.values.byName(model.state),
      failureBehavior: FailureBehavior.values.byName(model.failureBehavior),
      optionalReward: model.hasReward
          ? Reward(
              xp: model.rewardXp,
              titleId: model.rewardTitleId,
              achievementId: model.rewardAchievementId,
            )
          : null,
      repeatabilityRule: model.repeatabilityRule,
    );
  }
}
