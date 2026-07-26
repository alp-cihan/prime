import '../../../../core/domain/attribute_type.dart';
import '../entities/xp_transaction.dart';

abstract class XpLedgerRepository {
  /// Appends new transactions, skipping any whose [XpTransaction.idempotencyKey]
  /// already exists — append-only, never overwritten.
  Future<void> appendAll(List<XpTransaction> transactions);

  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  );

  Future<List<XpTransaction>> getAll();

  Future<int> sumLifetimeXp();

  Future<int> sumXpForAttribute(AttributeType type);
}
