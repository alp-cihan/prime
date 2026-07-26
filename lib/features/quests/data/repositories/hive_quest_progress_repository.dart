import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_keys.dart';
import '../../domain/entities/quest_progress.dart';
import '../../domain/repositories/quest_progress_repository.dart';
import '../mappers/quest_progress_mapper.dart';
import '../models/quest_progress_hive_model.dart';

/// Hive CE-backed [QuestProgressRepository]. Keyed by
/// `"{questId}|{yyyy-MM-dd}"` (see [HiveKeys.questProgress]) on an
/// already-UTC-date-normalized date, so at most one row can ever exist per
/// quest per day — a repeat `upsert` for the same day replaces it.
class HiveQuestProgressRepository implements QuestProgressRepository {
  HiveQuestProgressRepository(
    this._box, {
    QuestProgressMapper mapper = const QuestProgressMapper(),
  }) : _mapper = mapper;

  final Box<QuestProgressHiveModel> _box;
  final QuestProgressMapper _mapper;

  @override
  Future<QuestProgress?> getForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    final model = _box.get(HiveKeys.questProgress(questId, _normalize(date)));
    return model == null ? null : _mapper.toDomain(model);
  }

  @override
  Future<List<QuestProgress>> getForQuest(String questId) async {
    final progress =
        _box.values
            .where((model) => model.questId == questId)
            .map(_mapper.toDomain)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return progress;
  }

  @override
  Future<void> upsert(QuestProgress progress) async {
    final normalizedDate = _normalize(progress.date);
    final normalized = progress.copyWith(date: normalizedDate);
    await _box.put(
      HiveKeys.questProgress(progress.questId, normalizedDate),
      _mapper.toModel(normalized),
    );
  }

  @override
  Future<void> deleteAllForQuest(String questId) async {
    final keysToDelete = _box.keys.where((key) {
      final model = _box.get(key);
      return model != null && model.questId == questId;
    });
    await _box.deleteAll(keysToDelete);
  }

  DateTime _normalize(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}
