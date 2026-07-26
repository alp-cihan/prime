import 'package:hive_ce/hive.dart';

import '../../../../core/domain/attribute_type.dart';
import '../../../../core/persistence/hive_keys.dart';
import '../../domain/entities/xp_transaction.dart';
import '../../domain/repositories/xp_ledger_repository.dart';
import '../mappers/xp_transaction_mapper.dart';
import '../models/xp_transaction_hive_model.dart';

/// Hive CE-backed [XpLedgerRepository]. The box is keyed by
/// [XpTransaction.idempotencyKey] — not [XpTransaction.id] — so dedup is
/// enforced on the field the approved architecture actually designates for
/// idempotency (CLAUDE.md: "XP transactions must use idempotency keys").
/// Two transactions that happen to share an `id` but have different
/// `idempotencyKey`s are stored as two separate rows without conflict,
/// since `id` never participates in the box key; nothing is corrupted or
/// silently merged.
class HiveXpLedgerRepository implements XpLedgerRepository {
  HiveXpLedgerRepository(
    this._box, {
    XpTransactionMapper mapper = const XpTransactionMapper(),
  }) : _mapper = mapper;

  final Box<XpTransactionHiveModel> _box;
  final XpTransactionMapper _mapper;

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
    for (final transaction in transactions) {
      if (_box.containsKey(transaction.idempotencyKey)) {
        continue; // Append-only: an existing key is never overwritten.
      }
      await _box.put(transaction.idempotencyKey, _mapper.toModel(transaction));
    }
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    final normalized = DateTime.utc(date.year, date.month, date.day);
    final prefix = HiveKeys.xpSourceIdDatePrefix(questId, normalized);
    final matches =
        _box.values
            .where((model) => model.sourceId.startsWith(prefix))
            .map(_mapper.toDomain)
            .toList()
          ..sort(_byCreatedAtThenKey);
    return matches;
  }

  @override
  Future<List<XpTransaction>> getAll() async {
    final all = _box.values.map(_mapper.toDomain).toList()
      ..sort(_byCreatedAtThenKey);
    return all;
  }

  @override
  Future<int> sumLifetimeXp() async =>
      _box.values.fold<int>(0, (sum, model) => sum + model.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async {
    final name = type.name;
    return _box.values
        .where((model) => model.attribute == name)
        .fold<int>(0, (sum, model) => sum + model.finalXp);
  }

  /// Chronological, tie-broken by [XpTransaction.idempotencyKey] — every
  /// attribute row from one completion event shares the same `createdAt`,
  /// so `createdAt` alone is not always a total order.
  int _byCreatedAtThenKey(XpTransaction a, XpTransaction b) {
    final byDate = a.createdAt.compareTo(b.createdAt);
    if (byDate != 0) return byDate;
    return a.idempotencyKey.compareTo(b.idempotencyKey);
  }
}
