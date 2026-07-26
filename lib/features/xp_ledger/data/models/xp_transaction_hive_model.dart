import 'package:hive_ce/hive.dart';

import '../../../../core/persistence/hive_type_ids.dart';

part 'xp_transaction_hive_model.g.dart';

/// Persisted shape of an [XpTransaction]. `createdAt` is stored as UTC epoch
/// microseconds for the same reason as `QuestHiveModel.deadlineUtcMicros` —
/// no dependency on the reading machine's local timezone, and no precision
/// loss versus `DateTime`'s native microsecond resolution.
///
/// The box this model lives in is keyed by `idempotencyKey`, not by [id] —
/// see `HiveXpLedgerRepository` for why that is the correct dedup key.
///
/// Field index map — **never reuse or renumber**:
/// ```text
/// 0 id                6 finalXp
/// 1 sourceType         7 createdAtUtcMicros
/// 2 sourceId           8 idempotencyKey
/// 3 attribute
/// 4 baseXp
/// 5 modifiersApplied
/// ```
/// Next available index: 9.
@HiveType(typeId: HiveTypeIds.xpTransaction)
class XpTransactionHiveModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String sourceType;
  @HiveField(2)
  final String sourceId;
  @HiveField(3)
  final String attribute;
  @HiveField(4)
  final int baseXp;
  @HiveField(5)
  final Map<String, double> modifiersApplied;
  @HiveField(6)
  final int finalXp;
  @HiveField(7)
  final int createdAtUtcMicros;
  @HiveField(8)
  final String idempotencyKey;

  XpTransactionHiveModel({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.attribute,
    required this.baseXp,
    required this.modifiersApplied,
    required this.finalXp,
    required this.createdAtUtcMicros,
    required this.idempotencyKey,
  });
}
