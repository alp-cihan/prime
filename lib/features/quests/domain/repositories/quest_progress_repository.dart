import '../entities/quest_progress.dart';

abstract class QuestProgressRepository {
  Future<QuestProgress?> getForQuestAndDate(String questId, DateTime date);

  Future<List<QuestProgress>> getForQuest(String questId);

  Future<void> upsert(QuestProgress progress);
}
