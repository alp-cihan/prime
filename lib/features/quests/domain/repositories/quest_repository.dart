import '../entities/quest.dart';

abstract class QuestRepository {
  Future<List<Quest>> getAll();

  Future<Quest?> getById(String id);

  Stream<List<Quest>> watchAll();

  Future<void> upsert(Quest quest);
}
