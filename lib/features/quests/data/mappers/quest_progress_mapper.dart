import '../../domain/entities/quest_progress.dart';
import '../models/quest_progress_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [QuestProgress]. `date` is
/// always normalized to a UTC, date-only value before being stored — this
/// mapper re-normalizes defensively even though callers (the repository,
/// `CompleteQuestUseCase`) already do, so a stray un-normalized `DateTime`
/// can never silently create a second row for the same logical day.
class QuestProgressMapper {
  const QuestProgressMapper();

  QuestProgressHiveModel toModel(QuestProgress progress) {
    final normalized = _normalize(progress.date);
    return QuestProgressHiveModel(
      questId: progress.questId,
      dateUtcMicros: normalized.microsecondsSinceEpoch,
      progressValue: progress.progressValue,
      isComplete: progress.isComplete,
      notes: progress.notes,
      qualityRating: progress.qualityRating,
      timeSpentMicros: progress.timeSpent?.inMicroseconds,
    );
  }

  QuestProgress toDomain(QuestProgressHiveModel model) {
    return QuestProgress(
      questId: model.questId,
      date: DateTime.fromMicrosecondsSinceEpoch(
        model.dateUtcMicros,
        isUtc: true,
      ),
      progressValue: model.progressValue,
      isComplete: model.isComplete,
      notes: model.notes,
      qualityRating: model.qualityRating,
      timeSpent: model.timeSpentMicros == null
          ? null
          : Duration(microseconds: model.timeSpentMicros!),
    );
  }

  DateTime _normalize(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);
}
