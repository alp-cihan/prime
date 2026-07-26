import '../../../../core/domain/attribute_type.dart';

/// A stable tie-break order used only by [AttributeXpAllocator], kept
/// deliberately separate from [AttributeType]'s declaration order. The
/// `switch` expression is exhaustiveness-checked by the compiler: adding a
/// new [AttributeType] value without extending this getter is a compile-time
/// error, not a silent gap.
extension AttributeAllocationPriority on AttributeType {
  int get allocationPriority => switch (this) {
    AttributeType.health => 0,
    AttributeType.strength => 1,
    AttributeType.discipline => 2,
    AttributeType.knowledge => 3,
    AttributeType.career => 4,
    AttributeType.finance => 5,
    AttributeType.relationships => 6,
    AttributeType.mindfulness => 7,
  };
}

/// Distributes an integer XP total across [AttributeType] keys proportional
/// to their weights, using the largest-remainder method: each attribute's
/// share is floored, then the leftover whole points go to the attributes
/// with the highest fractional remainder, breaking ties via
/// [AttributeAllocationPriority]. The result always sums to exactly
/// [totalXp] — no XP is lost or invented by rounding.
class AttributeXpAllocator {
  const AttributeXpAllocator();

  Map<AttributeType, int> allocate(
    int totalXp,
    Map<AttributeType, int> weights,
  ) {
    final totalWeight = weights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    if (totalWeight == 0) {
      return {for (final type in weights.keys) type: 0};
    }

    final exactShares = <AttributeType, double>{};
    final floors = <AttributeType, int>{};
    var flooredSum = 0;
    for (final entry in weights.entries) {
      final exact = totalXp * entry.value / totalWeight;
      exactShares[entry.key] = exact;
      final floor = exact.floor();
      floors[entry.key] = floor;
      flooredSum += floor;
    }

    var remainder = totalXp - flooredSum;
    final result = Map<AttributeType, int>.from(floors);

    final byRemainderDesc = weights.keys.toList()
      ..sort((a, b) {
        final fractionA = exactShares[a]! - floors[a]!;
        final fractionB = exactShares[b]! - floors[b]!;
        final comparison = fractionB.compareTo(fractionA);
        if (comparison != 0) return comparison;
        return a.allocationPriority.compareTo(b.allocationPriority);
      });

    for (final type in byRemainderDesc) {
      if (remainder <= 0) break;
      result[type] = result[type]! + 1;
      remainder--;
    }

    return result;
  }
}
