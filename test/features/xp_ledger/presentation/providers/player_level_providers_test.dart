import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/presentation/providers/player_level_providers.dart';
import 'package:prime/features/xp_ledger/presentation/providers/xp_ledger_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

XpTransaction _tx(int finalXp) {
  return XpTransaction(
    id: 'q1|2026-01-10|0|health',
    sourceType: XpSourceType.quest,
    sourceId: 'q1|2026-01-10|0',
    attribute: AttributeType.health,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: DateTime.utc(2026, 1, 10),
    idempotencyKey: 'q1|health|2026-01-10|0',
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

  test('zero XP produces a Level 1 summary', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    final summary = await container.read(playerLevelSummaryProvider.future);

    expect(summary.totalXp, 0);
    expect(summary.currentLevel, 1);
    expect(summary.currentLevelStartXp, 0);
    expect(summary.xpIntoCurrentLevel, 0);
    expect(summary.xpNeededForNextLevel, 100); // floor(100 * 1^1.5)
    expect(summary.nextLevelXp, 100);
    expect(summary.progressRatio, 0.0);
  });

  test(
    'XP below the first threshold stays at Level 1 with partial progress',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);
      await container.read(xpLedgerRepositoryProvider).appendAll([_tx(40)]);

      final summary = await container.read(playerLevelSummaryProvider.future);

      expect(summary.currentLevel, 1);
      expect(summary.xpIntoCurrentLevel, 40);
      expect(summary.xpNeededForNextLevel, 100);
      expect(summary.progressRatio, closeTo(0.4, 0.0001));
    },
  );

  test('XP exactly at the threshold advances to the next level', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(xpLedgerRepositoryProvider).appendAll([_tx(100)]);

    final summary = await container.read(playerLevelSummaryProvider.future);

    expect(summary.currentLevel, 2);
    expect(summary.currentLevelStartXp, 100);
    expect(summary.xpIntoCurrentLevel, 0);
    expect(summary.xpNeededForNextLevel, 282); // floor(100 * 2^1.5)
  });

  test('XP above threshold reflects progress into the new level', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(xpLedgerRepositoryProvider).appendAll([_tx(150)]);

    final summary = await container.read(playerLevelSummaryProvider.future);

    expect(summary.currentLevel, 2);
    expect(summary.currentLevelStartXp, 100);
    expect(summary.xpIntoCurrentLevel, 50);
    expect(summary.nextLevelXp, 100 + 282);
  });

  test('large XP totals remain valid (no overflow/negative values)', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);
    await container.read(xpLedgerRepositoryProvider).appendAll([_tx(5000000)]);

    final summary = await container.read(playerLevelSummaryProvider.future);

    expect(summary.totalXp, 5000000);
    expect(summary.currentLevel, greaterThan(1));
    expect(summary.xpIntoCurrentLevel, greaterThanOrEqualTo(0));
    expect(summary.xpNeededForNextLevel, greaterThan(0));
    expect(summary.progressRatio, inInclusiveRange(0.0, 1.0));
  });
}
