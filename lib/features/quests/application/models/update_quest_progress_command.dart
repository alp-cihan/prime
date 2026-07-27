import '../../domain/services/quest_progress_policy.dart';

/// Input to [UpdateQuestProgressUseCase]. [amount] is ignored for
/// [QuestProgressOperation.complete] (binary quests jump straight to the
/// target).
class UpdateQuestProgressCommand {
  final String questId;
  final DateTime date;
  final QuestProgressOperation operation;
  final double amount;

  const UpdateQuestProgressCommand({
    required this.questId,
    required this.date,
    required this.operation,
    this.amount = 1,
  });
}
