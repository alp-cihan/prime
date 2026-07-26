import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/xp_transaction.dart';
import '../models/xp_transaction_hive_model.dart';

/// Explicit domain ↔ persistence mapping for [XpTransaction].
class XpTransactionMapper {
  const XpTransactionMapper();

  XpTransactionHiveModel toModel(XpTransaction transaction) {
    return XpTransactionHiveModel(
      id: transaction.id,
      sourceType: transaction.sourceType.name,
      sourceId: transaction.sourceId,
      attribute: transaction.attribute.name,
      baseXp: transaction.baseXp,
      modifiersApplied: Map<String, double>.from(transaction.modifiersApplied),
      finalXp: transaction.finalXp,
      createdAtUtcMicros: transaction.createdAt.toUtc().microsecondsSinceEpoch,
      idempotencyKey: transaction.idempotencyKey,
    );
  }

  XpTransaction toDomain(XpTransactionHiveModel model) {
    return XpTransaction(
      id: model.id,
      sourceType: XpSourceType.values.byName(model.sourceType),
      sourceId: model.sourceId,
      attribute: AttributeType.values.byName(model.attribute),
      baseXp: model.baseXp,
      modifiersApplied: Map<String, double>.from(model.modifiersApplied),
      finalXp: model.finalXp,
      createdAt: DateTime.fromMicrosecondsSinceEpoch(
        model.createdAtUtcMicros,
        isUtc: true,
      ),
      idempotencyKey: model.idempotencyKey,
    );
  }
}
