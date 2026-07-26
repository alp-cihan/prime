import 'package:hive_ce/hive.dart';

import '../../domain/entities/quest.dart';
import '../../domain/repositories/quest_repository.dart';
import '../mappers/quest_mapper.dart';
import '../models/quest_hive_model.dart';

/// Hive CE-backed [QuestRepository]. Keyed by `quest.id` directly, so
/// `upsert` on an existing id replaces rather than duplicates.
class HiveQuestRepository implements QuestRepository {
  HiveQuestRepository(this._box, {QuestMapper mapper = const QuestMapper()})
    : _mapper = mapper;

  final Box<QuestHiveModel> _box;
  final QuestMapper _mapper;

  @override
  Future<List<Quest>> getAll() async => _readAllSorted();

  @override
  Future<Quest?> getById(String id) async {
    final model = _box.get(id);
    return model == null ? null : _mapper.toDomain(model);
  }

  @override
  Stream<List<Quest>> watchAll() async* {
    yield _readAllSorted();
    yield* _box.watch().map((_) => _readAllSorted());
  }

  @override
  Future<void> upsert(Quest quest) async {
    await _box.put(quest.id, _mapper.toModel(quest));
  }

  @override
  Future<void> deleteById(String id) async {
    await _box.delete(id);
  }

  /// Sorted by id for deterministic reads — Hive's own iteration order is
  /// not a stable ordering contract to rely on.
  List<Quest> _readAllSorted() {
    final quests = _box.values.map(_mapper.toDomain).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return quests;
  }
}
