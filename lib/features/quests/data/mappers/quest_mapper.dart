import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/repeatability.dart';
import '../../domain/entities/reward.dart';
import '../models/quest_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [Quest]. Enums are stored as
/// their `.name` string rather than via a generated Hive enum adapter —
/// resilient to the enum's declaration order changing, and avoids spending
/// a `typeId` per enum.
///
/// [Repeatability] is the one exception: [QuestHiveModel.repeatabilityRule]
/// stays the original nullable `String?` (`null`/`'daily'`/`'weekly'`) it
/// always was — Phase 9 formalizes the *domain* type without touching the
/// persisted shape or its Hive field index, so no migration is needed and
/// pre-Phase-9 records read back correctly unchanged.
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
      repeatabilityRule: _ruleFromRepeatability(quest.repeatability),
      rewardXp: reward?.xp,
      rewardTitleId: reward?.titleId,
      rewardAchievementId: reward?.achievementId,
      hasReward: reward != null,
      visualKey: quest.visualKey,
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
      repeatability: _repeatabilityFromRule(model.repeatabilityRule),
      visualKey: model.visualKey,
    );
  }

  /// Unrecognized/legacy values (including `null`) fall back to [Repeatability.none]
  /// rather than throwing — the same permissiveness the rest of this
  /// codebase's `.byName()` calls don't need, since this is the one field
  /// whose persisted representation predates its domain enum.
  Repeatability _repeatabilityFromRule(String? rule) => switch (rule) {
    'daily' => Repeatability.daily,
    'weekly' => Repeatability.weekly,
    _ => Repeatability.none,
  };

  String? _ruleFromRepeatability(Repeatability repeatability) =>
      switch (repeatability) {
        Repeatability.none => null,
        Repeatability.daily => 'daily',
        Repeatability.weekly => 'weekly',
      };
}
