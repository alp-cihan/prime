import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'quest_progress_hive_model.g.dart';

/// Persisted shape of a [QuestProgress]. `date` is stored as UTC epoch
/// microseconds (already normalized to date-only by the mapper/repository)
/// and `timeSpent` as microseconds — both plain ints, so round-tripping
/// never depends on the reading machine's local timezone and never
/// truncates precision.
///
/// Field index map — **never reuse or renumber**:
/// ```text
/// 0 questId          4 notes
/// 1 dateUtcMicros     5 qualityRating
/// 2 progressValue     6 timeSpentMicros
/// 3 isComplete
/// ```
/// Next available index: 7.
@HiveType(typeId: HiveTypeIds.questProgress)
class QuestProgressHiveModel {
  @HiveField(0)
  final String questId;
  @HiveField(1)
  final int dateUtcMicros;
  @HiveField(2)
  final double progressValue;
  @HiveField(3)
  final bool isComplete;
  @HiveField(4)
  final String? notes;
  @HiveField(5)
  final int? qualityRating;
  @HiveField(6)
  final int? timeSpentMicros;

  QuestProgressHiveModel({
    required this.questId,
    required this.dateUtcMicros,
    required this.progressValue,
    required this.isComplete,
    this.notes,
    this.qualityRating,
    this.timeSpentMicros,
  });
}
