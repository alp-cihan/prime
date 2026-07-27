import '../../../../core/domain/attribute_type.dart';
import 'repeatability.dart';
import 'reward.dart';

/// docs/architecture.md §5.1. `repeatable` is the internal representation
/// for daily/weekly cadences and is never user-facing as a distinct type.
enum QuestType {
  daily,
  weekly,
  monthly,
  side,
  epic,
  mainStory,
  repeatable,
  recovery,
}

/// docs/architecture.md §3.2 — the endpoints (trivial=0.5, veryHard=1.6)
/// are architecture-pinned; the middle tiers are an even progression
/// between them, with `normal` at the neutral 1.0x multiplier.
enum QuestDifficulty { trivial, easy, normal, hard, veryHard }

enum ProgressType { binary, quantity, duration }

enum QuestCompletionState {
  notStarted,
  inProgress,
  complete,
  expired,
  converted,
}

enum FailureBehavior { expire, carryOver, convertToRecovery }

/// docs/architecture.md §15/§5.2. `linkedArea` (`LifeAreaType`) is
/// intentionally omitted — that enum is referenced by the architecture but
/// never defined anywhere in it; it is deferred to Phase 4 (Life Areas).
class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<AttributeType, int> attributeXpWeights;
  final List<String> linkedIdentityStatementIds;
  final ProgressType progressType;
  final double currentProgress;
  final double targetProgress;
  final DateTime? deadline;
  final String? questChainId;
  final List<String> prerequisiteQuestIds;
  final QuestCompletionState state;
  final FailureBehavior failureBehavior;
  final Reward? optionalReward;
  final Repeatability repeatability;

  const Quest({
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
    this.deadline,
    this.questChainId,
    required this.prerequisiteQuestIds,
    required this.state,
    required this.failureBehavior,
    this.optionalReward,
    this.repeatability = Repeatability.none,
  });

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestDifficulty? difficulty,
    Map<AttributeType, int>? attributeXpWeights,
    List<String>? linkedIdentityStatementIds,
    ProgressType? progressType,
    double? currentProgress,
    double? targetProgress,
    DateTime? deadline,
    String? questChainId,
    List<String>? prerequisiteQuestIds,
    QuestCompletionState? state,
    FailureBehavior? failureBehavior,
    Reward? optionalReward,
    Repeatability? repeatability,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      attributeXpWeights: attributeXpWeights ?? this.attributeXpWeights,
      linkedIdentityStatementIds:
          linkedIdentityStatementIds ?? this.linkedIdentityStatementIds,
      progressType: progressType ?? this.progressType,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      deadline: deadline ?? this.deadline,
      questChainId: questChainId ?? this.questChainId,
      prerequisiteQuestIds: prerequisiteQuestIds ?? this.prerequisiteQuestIds,
      state: state ?? this.state,
      failureBehavior: failureBehavior ?? this.failureBehavior,
      optionalReward: optionalReward ?? this.optionalReward,
      repeatability: repeatability ?? this.repeatability,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Quest) return false;
    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.difficulty == difficulty &&
        _mapEquals(other.attributeXpWeights, attributeXpWeights) &&
        _listEquals(
          other.linkedIdentityStatementIds,
          linkedIdentityStatementIds,
        ) &&
        other.progressType == progressType &&
        other.currentProgress == currentProgress &&
        other.targetProgress == targetProgress &&
        other.deadline == deadline &&
        other.questChainId == questChainId &&
        _listEquals(other.prerequisiteQuestIds, prerequisiteQuestIds) &&
        other.state == state &&
        other.failureBehavior == failureBehavior &&
        other.optionalReward == optionalReward &&
        other.repeatability == repeatability;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    type,
    difficulty,
    Object.hashAllUnordered(
      attributeXpWeights.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    Object.hashAll(linkedIdentityStatementIds),
    progressType,
    currentProgress,
    targetProgress,
    deadline,
    Object.hash(
      questChainId,
      Object.hashAll(prerequisiteQuestIds),
      state,
      failureBehavior,
      optionalReward,
      repeatability,
    ),
  );
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals(Map<AttributeType, int> a, Map<AttributeType, int> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
