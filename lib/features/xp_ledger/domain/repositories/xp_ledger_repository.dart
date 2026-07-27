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

  /// Every transaction ever recorded for [questId], across all dates —
  /// the append-only source of truth for "has this quest ever earned
  /// completion XP," used to gate non-repeatable quests against being
  /// rewarded more than once in their lifetime. Unlike `QuestProgress`
  /// (which is upserted per day and can be overwritten by a later
  /// decrement), ledger rows are never deleted or rewritten, so this is
  /// safe to use as a lifetime completion check.
  Future<List<XpTransaction>> getTransactionsForQuest(String questId);

  /// Every transaction recorded on [date], across all quests — the Today
  /// dashboard's "activity today" view. [date] must already be
  /// UTC-date-normalized, same convention as [getTransactionsForQuestAndDate].
  Future<List<XpTransaction>> getTransactionsForDate(DateTime date);

  Future<List<XpTransaction>> getAll();

  Future<int> sumLifetimeXp();

  Future<int> sumXpForAttribute(AttributeType type);
}
