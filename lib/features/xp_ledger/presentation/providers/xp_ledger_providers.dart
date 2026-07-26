import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/domain/attribute_type.dart';
import '../../../../core/providers/persistence_providers.dart';
import '../../data/repositories/hive_xp_ledger_repository.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/repositories/xp_ledger_repository.dart';

part 'xp_ledger_providers.g.dart';

/// Singleton for the app's lifetime — wraps the already-open XP ledger box.
@Riverpod(keepAlive: true)
XpLedgerRepository xpLedgerRepository(Ref ref) =>
    HiveXpLedgerRepository(ref.watch(xpTransactionHiveBoxProvider));

/// Transactions for one `(questId, date)`, deterministically ordered by the
/// repository. [date] must already be UTC-date-normalized — this provider's
/// family key is the exact [date] value, so a caller passing a raw,
/// un-normalized `DateTime` would create a separate cache entry per distinct
/// time-of-day instead of sharing one per calendar day. Every consumer in
/// this codebase (queries and `CompleteQuestController`'s invalidation)
/// normalizes before calling this provider — see
/// `CompleteQuestUseCase._normalizeDate` for the same convention.
@riverpod
Future<List<XpTransaction>> xpTransactionsForQuestAndDate(
  Ref ref,
  String questId,
  DateTime date,
) {
  final repository = ref.watch(xpLedgerRepositoryProvider);
  return repository.getTransactionsForQuestAndDate(questId, date);
}

/// Every transaction recorded on [date], across all quests. [date] must
/// already be UTC-date-normalized, for the same reason documented on
/// [xpTransactionsForQuestAndDate].
@riverpod
Future<List<XpTransaction>> xpTransactionsForDate(Ref ref, DateTime date) {
  final repository = ref.watch(xpLedgerRepositoryProvider);
  return repository.getTransactionsForDate(date);
}

/// Lifetime total XP, derived fresh from the ledger every time — never a
/// stored/cached total (CLAUDE.md: "Cached XP totals are projections, not
/// the source of truth").
@riverpod
Future<int> totalXp(Ref ref) {
  final repository = ref.watch(xpLedgerRepositoryProvider);
  return repository.sumLifetimeXp();
}

/// Lifetime XP grouped by attribute, derived the same way — one
/// `sumXpForAttribute` call per attribute, run concurrently.
@riverpod
Future<Map<AttributeType, int>> xpByAttribute(Ref ref) async {
  final repository = ref.watch(xpLedgerRepositoryProvider);
  final result = <AttributeType, int>{};
  await Future.wait(
    AttributeType.values.map((type) async {
      result[type] = await repository.sumXpForAttribute(type);
    }),
  );
  return result;
}
