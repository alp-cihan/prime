import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';

void main() {
  test('XpTransaction supports value equality', () {
    final createdAt = DateTime(2026, 1, 1);
    final a = XpTransaction(
      id: 'x1',
      sourceType: XpSourceType.quest,
      sourceId: 'q1',
      attribute: AttributeType.health,
      baseXp: 70,
      modifiersApplied: const {'difficulty': 1.0},
      finalXp: 70,
      createdAt: createdAt,
      idempotencyKey: 'q1|health|2026-01-01|0',
    );
    final b = XpTransaction(
      id: 'x1',
      sourceType: XpSourceType.quest,
      sourceId: 'q1',
      attribute: AttributeType.health,
      baseXp: 70,
      modifiersApplied: const {'difficulty': 1.0},
      finalXp: 70,
      createdAt: createdAt,
      idempotencyKey: 'q1|health|2026-01-01|0',
    );

    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
