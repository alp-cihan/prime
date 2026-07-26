import '../entities/quest.dart';

abstract class QuestRepository {
  Future<List<Quest>> getAll();

  Future<Quest?> getById(String id);

  Stream<List<Quest>> watchAll();

  Future<void> upsert(Quest quest);

  /// Removes the quest record itself. Callers are responsible for deciding
  /// what happens to related [QuestProgress]/`XpTransaction` rows — this
  /// repository only ever touches the quest box (see
  /// `DeleteQuestUseCase` for the Phase 7 deletion policy). A no-op if [id]
  /// does not exist.
  Future<void> deleteById(String id);
}
