import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/xp_ledger/data/repositories/hive_xp_ledger_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

XpTransaction _tx({
  required String questId,
  required String dateKey,
  required int repeatIndex,
  AttributeType attribute = AttributeType.health,
  int finalXp = 100,
}) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {'difficulty': 1.0},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10, 9),
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

  test('xpLedgerRepositoryProvider returns a HiveXpLedgerRepository', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    expect(
      container.read(xpLedgerRepositoryProvider),
      isA<HiveXpLedgerRepository>(),
    );
  });

  test('xpTransactionsForQuestAndDate returns only matching rows', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final repository = container.read(xpLedgerRepositoryProvider);
    await repository.appendAll([
      _tx(questId: 'q1', dateKey: '2026-01-10', repeatIndex: 0),
      _tx(questId: 'q1', dateKey: '2026-01-11', repeatIndex: 0),
      _tx(questId: 'q2', dateKey: '2026-01-10', repeatIndex: 0),
    ]);

    final result = await container.read(
      xpTransactionsForQuestAndDateProvider(
        'q1',
        DateTime.utc(2026, 1, 10),
      ).future,
    );

    expect(result.length, 1);
    expect(result.single.sourceId, 'q1|2026-01-10|0');
  });

  test('totalXp sums finalXp across every transaction', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final repository = container.read(xpLedgerRepositoryProvider);
    await repository.appendAll([
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
    ]);

    expect(await container.read(totalXpProvider.future), 100);
  });

  test('xpByAttribute groups totals correctly', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    final repository = container.read(xpLedgerRepositoryProvider);
    await repository.appendAll([
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
      _tx(
        questId: 'q1',
        dateKey: '2026-01-11',
        repeatIndex: 0,
        attribute: AttributeType.health,
        finalXp: 10,
      ),
    ]);

    final byAttribute = await container.read(xpByAttributeProvider.future);

    expect(byAttribute[AttributeType.health], 80);
    expect(byAttribute[AttributeType.strength], 30);
    expect(byAttribute[AttributeType.knowledge], 0);
  });

  test(
    'an empty ledger yields zero total and all-zero per-attribute totals',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      expect(await container.read(totalXpProvider.future), 0);
      final byAttribute = await container.read(xpByAttributeProvider.future);
      expect(byAttribute.values.every((xp) => xp == 0), isTrue);
      expect(byAttribute.length, AttributeType.values.length);
    },
  );

  test(
    'a duplicate idempotency retry does not inflate derived totals',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      final repository = container.read(xpLedgerRepositoryProvider);
      final transaction = _tx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        finalXp: 100,
      );

      await repository.appendAll([transaction]);
      await repository.appendAll([transaction]); // retry, same idempotencyKey

      expect(await container.read(totalXpProvider.future), 100);
    },
  );
}
