import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';

import '../../../../support/hive_test_support.dart';

XpTransaction _tx({
  required String questId,
  required String dateKey,
  required int repeatIndex,
  AttributeType attribute = AttributeType.health,
  int finalXp = 100,
  DateTime? createdAt,
  String? idOverride,
}) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: idOverride ?? '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: finalXp,
    createdAt: createdAt ?? DateTime.utc(2026, 1, 10, 9),
    idempotencyKey: '$questId|${attribute.name}|$dateKey|$repeatIndex',
  );
}

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  Future<Box<XpTransactionHiveModel>> openBox() =>
      Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

  test('appendAll then getAll returns what was appended', () async {
    final box = await openBox();
    final repo = HiveXpLedgerRepository(box);
    final transaction = _tx(
      questId: 'q1',
      dateKey: '2026-01-10',
      repeatIndex: 0,
    );

    await repo.appendAll([transaction]);
    final all = await repo.getAll();

    expect(all, [transaction]);
  });

  test(
    'appendAll skips a transaction whose idempotencyKey already exists',
    () async {
      final box = await openBox();
      final repo = HiveXpLedgerRepository(box);
      final original = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        finalXp: 100,
      );
      final differentPayloadSameKey = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        finalXp: 999,
      );

      await repo.appendAll([original]);
      await repo.appendAll([differentPayloadSameKey]);

      final all = await repo.getAll();
      expect(all.length, 1);
      expect(
        all.single.finalXp,
        100,
      ); // the original write is never overwritten
    },
  );

  test(
    'a duplicate transaction id with a different idempotencyKey does not corrupt or overwrite data',
    () async {
      final box = await openBox();
      final repo = HiveXpLedgerRepository(box);
      final first = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        idOverride: 'shared-id',
      );
      final second = _tx(
        questId: 'q1',
        dateKey: '2026-01-11',
        repeatIndex: 0,
        idOverride: 'shared-id',
      );

      await repo.appendAll([first, second]);

      final all = await repo.getAll();
      // The box is keyed by idempotencyKey, not id, so both rows are kept —
      // a shared `id` is not the dedup key and causes no data loss.
      expect(all.length, 2);
      expect(all.map((t) => t.idempotencyKey).toSet(), {
        first.idempotencyKey,
        second.idempotencyKey,
      });
    },
  );

  test(
    'retrying appendAll with the already-recorded transactions does not duplicate XP',
    () async {
      final box = await openBox();
      final repo = HiveXpLedgerRepository(box);
      final transactions = [
        _tx(
          questId: 'q1',
          dateKey: '2026-01-10',
          repeatIndex: 0,
          attribute: AttributeType.health,
          finalXp: 70,
        ),
        _tx(
          questId: 'q1',
          dateKey: '2026-01-10',
          repeatIndex: 0,
          attribute: AttributeType.strength,
          finalXp: 30,
        ),
      ];

      await repo.appendAll(transactions);
      final totalBefore = await repo.sumLifetimeXp();

      await repo.appendAll(transactions); // simulated retry, identical payload
      final totalAfter = await repo.sumLifetimeXp();

      expect(totalAfter, totalBefore);
      expect(totalAfter, 100);
    },
  );

  test('getTransactionsForQuestAndDate returns only matching rows', () async {
    final box = await openBox();
    final repo = HiveXpLedgerRepository(box);

    final matchDay1 = _tx(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0);
    final matchDay1Repeat = _tx(
      questId: 'q1',
      dateKey: '2026-01-10',
      repeatIndex: 1,
    );
    final otherDay = _tx(questId: 'q1', dateKey: '2026-01-11', repeatIndex: 0);
    final otherQuest = _tx(
      questId: 'q2',
      dateKey: '2026-01-10',
      repeatIndex: 0,
    );

    await repo.appendAll([matchDay1, matchDay1Repeat, otherDay, otherQuest]);

    final result = await repo.getTransactionsForQuestAndDate(
      'q1',
      DateTime.utc(2026, 1, 10),
    );
    expect(result.map((t) => t.idempotencyKey).toSet(), {
      matchDay1.idempotencyKey,
      matchDay1Repeat.idempotencyKey,
    });
  });

  test(
    'getAll returns rows in deterministic order (createdAt, then idempotencyKey)',
    () async {
      final box = await openBox();
      final repo = HiveXpLedgerRepository(box);

      final later = _tx(
        questId: 'q1',
        dateKey: '2026-01-11',
        repeatIndex: 0,
        createdAt: DateTime.utc(2026, 1, 11),
      );
      final earlierB = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        attribute: AttributeType.strength,
        createdAt: DateTime.utc(2026, 1, 10),
      );
      final earlierA = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        attribute: AttributeType.health,
        createdAt: DateTime.utc(2026, 1, 10),
      );

      // Insert out of order; two rows share the same createdAt.
      await repo.appendAll([later, earlierB, earlierA]);

      final all = await repo.getAll();
      expect(all, [earlierA, earlierB, later]); // tie broken by idempotencyKey
    },
  );

  test(
    'append-only: nothing in the repository interface can modify or remove an existing row',
    () async {
      final box = await openBox();
      final repo = HiveXpLedgerRepository(box);
      final transaction = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
      );

      await repo.appendAll([transaction]);
      await repo.appendAll([
        transaction,
        _tx(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 1),
      ]);

      final all = await repo.getAll();
      expect(all.length, 2);
      expect(
        all.any(
          (t) =>
              t.idempotencyKey == transaction.idempotencyKey &&
              t.finalXp == transaction.finalXp,
        ),
        isTrue,
      );
    },
  );

  test('persistence survives closing and reopening the box', () async {
    final box = await openBox();
    final repo = HiveXpLedgerRepository(box);
    final transaction = _tx(
      questId: 'q1',
      dateKey: '2026-01-10',
      repeatIndex: 0,
    );
    await repo.appendAll([transaction]);

    await support.reopen();
    final reopenedBox = await openBox();
    final reopenedRepo = HiveXpLedgerRepository(reopenedBox);

    final all = await reopenedRepo.getAll();
    expect(all, [transaction]);
    expect(await reopenedRepo.sumLifetimeXp(), transaction.finalXp);
  });
}
