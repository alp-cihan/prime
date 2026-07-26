import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/xp_ledger/data/mappers/xp_transaction_mapper.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';

void main() {
  const mapper = XpTransactionMapper();

  XpTransaction buildTransaction({DateTime? createdAt}) {
    return XpTransaction(
      id: 'q1|2026-01-10|0|health',
      sourceType: XpSourceType.quest,
      sourceId: 'q1|2026-01-10|0',
      attribute: AttributeType.health,
      baseXp: 70,
      modifiersApplied: const {
        'difficulty': 1.3,
        'completionRatio': 1.0,
        'consistency': 1.04,
        'quality': 1.2,
        'firstCompletionBonus': 1.25,
        'diminishingReturns': 1.0,
      },
      finalXp: 125,
      createdAt: createdAt ?? DateTime.utc(2026, 1, 10, 9, 30),
      idempotencyKey: 'q1|health|2026-01-10|0',
    );
  }

  test('round-trips every currently persisted field', () {
    final transaction = buildTransaction();
    final roundTripped = mapper.toDomain(mapper.toModel(transaction));
    expect(roundTripped, transaction);
  });

  test('enum fields survive the round trip', () {
    final transaction = buildTransaction();
    final roundTripped = mapper.toDomain(mapper.toModel(transaction));
    expect(roundTripped.sourceType, transaction.sourceType);
    expect(roundTripped.attribute, transaction.attribute);
  });

  test('modifiersApplied map survives the round trip exactly', () {
    final transaction = buildTransaction();
    final roundTripped = mapper.toDomain(mapper.toModel(transaction));
    expect(roundTripped.modifiersApplied, transaction.modifiersApplied);
  });

  test(
    'createdAt preserves the exact instant and microsecond precision, even from a local DateTime',
    () {
      final localMoment = DateTime.now(); // deliberately local, not UTC
      final transaction = buildTransaction(createdAt: localMoment);
      final roundTripped = mapper.toDomain(mapper.toModel(transaction));
      // Dart's DateTime== requires the same zone flag as well as the same
      // instant (a local DateTime is never == its UTC equivalent), so the
      // round-tripped value (always UTC-flagged) is compared via
      // isAtSameMomentAs — the correct check for "was the instant preserved".
      expect(roundTripped.createdAt.isAtSameMomentAs(localMoment), isTrue);
      expect(
        roundTripped.createdAt.microsecondsSinceEpoch,
        localMoment.microsecondsSinceEpoch,
      );
    },
  );
}
