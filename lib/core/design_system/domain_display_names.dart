import '../domain/attribute_type.dart';
import '../../features/quests/domain/entities/quest.dart';

/// Presentation-only display strings for domain enums. Kept here (not in
/// domain) since domain must stay pure business logic with no UI-facing
/// formatting concerns; kept as plain functions (not widgets) so they're
/// usable from any dumb widget without pulling in Riverpod or BuildContext.
String attributeDisplayName(AttributeType type) {
  switch (type) {
    case AttributeType.health:
      return 'Health';
    case AttributeType.strength:
      return 'Strength';
    case AttributeType.discipline:
      return 'Discipline';
    case AttributeType.knowledge:
      return 'Knowledge';
    case AttributeType.career:
      return 'Career';
    case AttributeType.finance:
      return 'Finance';
    case AttributeType.relationships:
      return 'Relationships';
    case AttributeType.mindfulness:
      return 'Mindfulness';
  }
}

String questDifficultyDisplayName(QuestDifficulty difficulty) {
  switch (difficulty) {
    case QuestDifficulty.trivial:
      return 'Trivial';
    case QuestDifficulty.easy:
      return 'Easy';
    case QuestDifficulty.normal:
      return 'Normal';
    case QuestDifficulty.hard:
      return 'Hard';
    case QuestDifficulty.veryHard:
      return 'Very Hard';
  }
}

String questTypeDisplayName(QuestType type) {
  switch (type) {
    case QuestType.daily:
      return 'Daily Quest';
    case QuestType.weekly:
      return 'Weekly Quest';
    case QuestType.monthly:
      return 'Monthly Quest';
    case QuestType.side:
      return 'Side Quest';
    case QuestType.epic:
      return 'Epic Quest';
    case QuestType.mainStory:
      return 'Main Story Quest';
    case QuestType.repeatable:
      return 'Repeatable Quest';
    case QuestType.recovery:
      return 'Recovery Quest';
  }
}

String questCompletionStateDisplayName(QuestCompletionState state) {
  switch (state) {
    case QuestCompletionState.notStarted:
      return 'Not started';
    case QuestCompletionState.inProgress:
      return 'In progress';
    case QuestCompletionState.complete:
      return 'Complete';
    case QuestCompletionState.expired:
      return 'Expired';
    case QuestCompletionState.converted:
      return 'Converted';
  }
}
