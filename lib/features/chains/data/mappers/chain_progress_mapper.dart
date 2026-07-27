import '../../domain/entities/chain_progress.dart';
import '../models/chain_progress_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [ChainProgress].
class ChainProgressMapper {
  const ChainProgressMapper();

  ChainProgressHiveModel toModel(ChainProgress progress) {
    return ChainProgressHiveModel(
      chainId: progress.chainId,
      completedStageCount: progress.completedStageCount,
      completedAtUtcMicros: progress.completedAt
          ?.toUtc()
          .microsecondsSinceEpoch,
    );
  }

  ChainProgress toDomain(ChainProgressHiveModel model) {
    return ChainProgress(
      chainId: model.chainId,
      completedStageCount: model.completedStageCount,
      completedAt: model.completedAtUtcMicros == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              model.completedAtUtcMicros!,
              isUtc: true,
            ),
    );
  }
}
