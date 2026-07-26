import '../entities/quest_progress.dart';

abstract class QuestProgressRepository {
  Future<QuestProgress?> getForQuestAndDate(String questId, DateTime date);

  Future<List<QuestProgress>> getForQuest(String questId);

  Future<void> upsert(QuestProgress progress);

  /// Removes every progress row for [questId], across all dates — used by
  /// `DeleteQuestUseCase` (docs/architecture.md has no cascading-delete rule
  /// for `XpTransaction`, so that ledger is deliberately untouched by this
  /// method; only progress rows, which have no historical-audit purpose of
  /// their own once the quest is gone, are removed). A no-op if none exist.
  Future<void> deleteAllForQuest(String questId);
}
