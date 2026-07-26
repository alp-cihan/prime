import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'quest_hive_model.g.dart';

/// Persisted shape of a [Quest]. `Reward` is flattened into three nullable
/// fields plus [hasReward] — a bool is needed to distinguish "no reward at
/// all" from the degenerate case of a present-but-empty `Reward` (every one
/// of its fields nullable), so round-tripping never silently loses that
/// distinction. `deadline` is stored as UTC epoch **microseconds** (see the
/// mapper) rather than via Hive's built-in `DateTime` support: that support
/// both reconstructs in local time (reading it back through `.year`/
/// `.month`/`.day` on a machine in a different timezone would silently
/// shift the date) and — as caught by this phase's own round-trip tests —
/// storing as epoch *milliseconds* truncates `DateTime`'s microsecond
/// precision. Microseconds avoids both problems.
///
/// Field index map — **never reuse or renumber**:
/// ```text
///  0 id                          11 questChainId
///  1 title                       12 prerequisiteQuestIds
///  2 description                 13 state
///  3 type                        14 failureBehavior
///  4 difficulty                  15 repeatabilityRule
///  5 attributeXpWeights          16 rewardXp
///  6 linkedIdentityStatementIds  17 rewardTitleId
///  7 progressType                18 rewardAchievementId
///  8 currentProgress             19 hasReward
///  9 targetProgress
/// 10 deadlineUtcMicros
/// ```
/// Next available index: 20. This is the migration boundary — any future
/// field is added with index 20 onward, never by reusing a gap above.
@HiveType(typeId: HiveTypeIds.quest)
class QuestHiveModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String type;
  @HiveField(4)
  final String difficulty;
  @HiveField(5)
  final Map<String, int> attributeXpWeights;
  @HiveField(6)
  final List<String> linkedIdentityStatementIds;
  @HiveField(7)
  final String progressType;
  @HiveField(8)
  final double currentProgress;
  @HiveField(9)
  final double targetProgress;
  @HiveField(10)
  final int? deadlineUtcMicros;
  @HiveField(11)
  final String? questChainId;
  @HiveField(12)
  final List<String> prerequisiteQuestIds;
  @HiveField(13)
  final String state;
  @HiveField(14)
  final String failureBehavior;
  @HiveField(15)
  final String? repeatabilityRule;
  @HiveField(16)
  final int? rewardXp;
  @HiveField(17)
  final String? rewardTitleId;
  @HiveField(18)
  final String? rewardAchievementId;
  @HiveField(19)
  final bool hasReward;

  QuestHiveModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.attributeXpWeights,
    required this.linkedIdentityStatementIds,
    required this.progressType,
    required this.currentProgress,
    required this.targetProgress,
    this.deadlineUtcMicros,
    this.questChainId,
    required this.prerequisiteQuestIds,
    required this.state,
    required this.failureBehavior,
    this.repeatabilityRule,
    this.rewardXp,
    this.rewardTitleId,
    this.rewardAchievementId,
    this.hasReward = false,
  });
}
