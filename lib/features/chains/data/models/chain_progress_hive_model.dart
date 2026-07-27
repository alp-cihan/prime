import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'chain_progress_hive_model.g.dart';

/// Persisted shape of a [ChainProgress]. `completedAt` is stored as UTC
/// epoch microseconds (same convention as every other timestamped model in
/// this codebase) when present, `null` otherwise.
///
/// Field index map — **never reuse or renumber**:
/// ```text
/// 0 chainId              2 completedAtUtcMicros
/// 1 completedStageCount
/// ```
/// Next available index: 3.
@HiveType(typeId: HiveTypeIds.chainProgress)
class ChainProgressHiveModel {
  @HiveField(0)
  final String chainId;
  @HiveField(1)
  final int completedStageCount;
  @HiveField(2)
  final int? completedAtUtcMicros;

  ChainProgressHiveModel({
    required this.chainId,
    required this.completedStageCount,
    this.completedAtUtcMicros,
  });
}
