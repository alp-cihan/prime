import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/quests/domain/services/attribute_xp_allocator.dart';

void main() {
  const allocator = AttributeXpAllocator();

  test('allocates weights exactly when the total divides evenly', () {
    final result = allocator.allocate(135, {
      AttributeType.health: 70,
      AttributeType.strength: 40,
      AttributeType.discipline: 25,
    });
    expect(result, {
      AttributeType.health: 70,
      AttributeType.strength: 40,
      AttributeType.discipline: 25,
    });
  });

  test('gives the remainder to the highest fractional share', () {
    final result = allocator.allocate(28, {
      AttributeType.health: 10,
      AttributeType.strength: 10,
      AttributeType.discipline: 11,
    });
    expect(result, {
      AttributeType.health: 9,
      AttributeType.strength: 9,
      AttributeType.discipline: 10,
    });
  });

  test(
    'breaks exact ties using the explicit allocationPriority, not enum declaration order',
    () {
      final result = allocator.allocate(29, {
        AttributeType.health: 10,
        AttributeType.strength: 10,
        AttributeType.discipline: 10,
      });
      expect(result, {
        AttributeType.health: 10,
        AttributeType.strength: 10,
        AttributeType.discipline: 9,
      });
    },
  );

  test('tie-break is deterministic and repeatable across repeated calls', () {
    final weights = {
      AttributeType.mindfulness: 10,
      AttributeType.finance: 10,
      AttributeType.career: 10,
    };
    final first = allocator.allocate(29, weights);
    for (var i = 0; i < 5; i++) {
      expect(allocator.allocate(29, weights), first);
    }
  });

  test('allocationPriority is total and matches the documented order', () {
    const expectedOrder = [
      AttributeType.health,
      AttributeType.strength,
      AttributeType.discipline,
      AttributeType.knowledge,
      AttributeType.career,
      AttributeType.finance,
      AttributeType.relationships,
      AttributeType.mindfulness,
    ];
    for (var i = 0; i < expectedOrder.length; i++) {
      expect(expectedOrder[i].allocationPriority, i);
    }
  });

  test(
    'always sums to exactly the requested total across a range of totals and weights',
    () {
      final weightSets = [
        {
          AttributeType.health: 70,
          AttributeType.strength: 40,
          AttributeType.discipline: 25,
        },
        {
          AttributeType.knowledge: 1,
          AttributeType.career: 1,
          AttributeType.finance: 1,
          AttributeType.relationships: 1,
        },
        {AttributeType.mindfulness: 3},
      ];
      for (final weights in weightSets) {
        for (final total in [0, 1, 2, 3, 7, 28, 99, 1000]) {
          final result = allocator.allocate(total, weights);
          expect(result.values.fold<int>(0, (sum, v) => sum + v), total);
          expect(result.values.every((v) => v >= 0), isTrue);
        }
      }
    },
  );

  test('returns all zeros when total weight is zero', () {
    final result = allocator.allocate(10, {
      AttributeType.health: 0,
      AttributeType.strength: 0,
    });
    expect(result, {AttributeType.health: 0, AttributeType.strength: 0});
  });
}
