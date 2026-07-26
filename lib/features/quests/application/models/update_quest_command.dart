import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/quest.dart';

/// Input to [UpdateQuestUseCase]. Carries the same editable field set as
/// [CreateQuestCommand] plus [questId] — every other [Quest] field (`state`,
/// `currentProgress`, quest-chain/identity/reward/deadline fields) is
/// preserved unchanged from the existing record (see that use case's class
/// doc for why editing must never touch them).
class UpdateQuestCommand {
  final String questId;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<AttributeType, int> attributeXpWeights;
  final ProgressType progressType;
  final double targetProgress;
  final String? repeatabilityRule;

  const UpdateQuestCommand({
    required this.questId,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.attributeXpWeights,
    required this.progressType,
    required this.targetProgress,
    this.repeatabilityRule,
  });
}
