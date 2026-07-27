import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/services/quest_xp_calculator.dart';

void main() {
  const calculator = QuestXpCalculator();

  QuestXpAllocation okOf(Result<QuestXpAllocation> result) {
    expect(result, isA<Ok<QuestXpAllocation>>());
    return (result as Ok<QuestXpAllocation>).value;
  }

  group('neutral baseline', () {
    test(
      'with every multiplier neutral, total equals the sum of attribute weights exactly',
      () {
        final result = calculator.calculate(
          attributeXpWeights: {
            AttributeType.health: 70,
            AttributeType.strength: 40,
            AttributeType.discipline: 25,
          },
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          qualityRating: null,
          repeatIndexInOccurrence: 0,
          priorXpEarnedInOccurrence: 0,
          isFirstCompletionEver: false,
        );

        final allocation = okOf(result);
        expect(allocation.totalXp, 135);
        expect(allocation.xpByAttribute, {
          AttributeType.health: 70,
          AttributeType.strength: 40,
          AttributeType.discipline: 25,
        });
        expect(
          allocation.xpByAttribute.values.fold<int>(0, (sum, v) => sum + v),
          allocation.totalXp,
        );
      },
    );
  });

  group('difficulty multipliers', () {
    for (final entry in {
      QuestDifficulty.trivial: 50,
      QuestDifficulty.easy: 75,
      QuestDifficulty.normal: 100,
      QuestDifficulty.hard: 130,
      QuestDifficulty.veryHard: 160,
    }.entries) {
      test(
        '${entry.key} scales a base-100 single-attribute quest to ${entry.value}',
        () {
          final allocation = okOf(
            calculator.calculate(
              attributeXpWeights: {AttributeType.knowledge: 100},
              difficulty: entry.key,
              completionRatio: 1.0,
              consecutiveDayStreak: 0,
              repeatIndexInOccurrence: 0,
              priorXpEarnedInOccurrence: 0,
              isFirstCompletionEver: false,
            ),
          );
          expect(allocation.totalXp, entry.value);
        },
      );
    }
  });

  test('firstCompletionBonus multiplies the rounded core by 1.25', () {
    final allocation = okOf(
      calculator.calculate(
        attributeXpWeights: {AttributeType.career: 100},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 0,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: true,
      ),
    );
    expect(allocation.totalXp, 125);
  });

  group('diminishing returns on same-day repeats', () {
    test('2nd completion today earns half XP', () {
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {AttributeType.career: 100},
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          repeatIndexInOccurrence: 1,
          priorXpEarnedInOccurrence: 100,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 50);
    });

    test('3rd+ completion today earns a quarter XP', () {
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {AttributeType.career: 100},
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          repeatIndexInOccurrence: 2,
          priorXpEarnedInOccurrence: 150,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 25);
    });
  });

  group('quest-level daily cap', () {
    test('clamps to remaining headroom, not per attribute', () {
      // dailyCap = 100 * 1.0 * 2 = 200. Already earned 190 today, so at most 10 more.
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {
            AttributeType.health: 60,
            AttributeType.strength: 40,
          },
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          repeatIndexInOccurrence: 0,
          priorXpEarnedInOccurrence: 190,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 10);
      expect(
        allocation.xpByAttribute.values.fold<int>(0, (sum, v) => sum + v),
        10,
      );
    });

    test('prior XP already at the cap produces zero new XP', () {
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {
            AttributeType.health: 60,
            AttributeType.strength: 40,
          },
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          repeatIndexInOccurrence: 0,
          priorXpEarnedInOccurrence: 200,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 0);
      expect(allocation.xpByAttribute, {
        AttributeType.health: 0,
        AttributeType.strength: 0,
      });
    });

    test(
      'prior XP already above the cap (e.g. a difficulty edit after logging) produces zero new XP',
      () {
        final allocation = okOf(
          calculator.calculate(
            attributeXpWeights: {
              AttributeType.health: 60,
              AttributeType.strength: 40,
            },
            difficulty: QuestDifficulty.normal,
            completionRatio: 1.0,
            consecutiveDayStreak: 0,
            repeatIndexInOccurrence: 0,
            priorXpEarnedInOccurrence: 500,
            isFirstCompletionEver: false,
          ),
        );
        expect(allocation.totalXp, 0);
        expect(allocation.xpByAttribute, {
          AttributeType.health: 0,
          AttributeType.strength: 0,
        });
      },
    );
  });

  test('consistency multiplier caps at +0.3 from day 15 onward', () {
    final day15 = okOf(
      calculator.calculate(
        attributeXpWeights: {AttributeType.mindfulness: 100},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 15,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      ),
    );
    final day30 = okOf(
      calculator.calculate(
        attributeXpWeights: {AttributeType.mindfulness: 100},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 30,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      ),
    );
    expect(day15.totalXp, 130);
    expect(day30.totalXp, 130);
  });

  group('allocation invariants', () {
    test('remainder goes to the attribute with the highest fractional share', () {
      // total=28 across weights 10/10/11 (sum 31): shares 9.032/9.032/9.935 -> discipline gets the +1.
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {
            AttributeType.health: 10,
            AttributeType.strength: 10,
            AttributeType.discipline: 11,
          },
          difficulty: QuestDifficulty.normal,
          completionRatio: 1.0,
          consecutiveDayStreak: 0,
          qualityRating: 2, // 0.9 multiplier: round(31 * 0.9) = 28
          repeatIndexInOccurrence: 0,
          priorXpEarnedInOccurrence: 0,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 28);
      expect(allocation.xpByAttribute, {
        AttributeType.health: 9,
        AttributeType.strength: 9,
        AttributeType.discipline: 10,
      });
    });

    test('ties break by the explicit, stable allocation priority', () {
      // total=29 across equal weights 10/10/10: shares 9.667 each, remainder=2 -> health, strength win the tie.
      final allocation = okOf(
        calculator.calculate(
          attributeXpWeights: {
            AttributeType.health: 10,
            AttributeType.strength: 10,
            AttributeType.discipline: 10,
          },
          difficulty: QuestDifficulty.normal,
          completionRatio: 29 / 30,
          consecutiveDayStreak: 0,
          repeatIndexInOccurrence: 0,
          priorXpEarnedInOccurrence: 0,
          isFirstCompletionEver: false,
        ),
      );
      expect(allocation.totalXp, 29);
      expect(allocation.xpByAttribute, {
        AttributeType.health: 10,
        AttributeType.strength: 10,
        AttributeType.discipline: 9,
      });
    });

    test(
      'allocated attribute XP always sums exactly to the final quest XP, for a range of weights and modifiers',
      () {
        final cases = [
          (
            weights: {
              AttributeType.health: 70,
              AttributeType.strength: 40,
              AttributeType.discipline: 25,
            },
            quality: 3,
            streak: 7,
          ),
          (
            weights: {AttributeType.knowledge: 33, AttributeType.career: 17},
            quality: 1,
            streak: 22,
          ),
          (
            weights: {
              AttributeType.finance: 1,
              AttributeType.relationships: 1,
              AttributeType.mindfulness: 1,
            },
            quality: 4,
            streak: 0,
          ),
          (weights: {AttributeType.health: 100}, quality: null, streak: 100),
        ];

        for (final testCase in cases) {
          final allocation = okOf(
            calculator.calculate(
              attributeXpWeights: testCase.weights,
              difficulty: QuestDifficulty.hard,
              completionRatio: 0.73,
              consecutiveDayStreak: testCase.streak,
              qualityRating: testCase.quality,
              repeatIndexInOccurrence: 0,
              priorXpEarnedInOccurrence: 0,
              isFirstCompletionEver: true,
            ),
          );
          expect(
            allocation.xpByAttribute.values.fold<int>(0, (sum, v) => sum + v),
            allocation.totalXp,
          );
          expect(allocation.xpByAttribute.values.every((v) => v >= 0), isTrue);
        }
      },
    );
  });

  group('validation', () {
    test('rejects an empty attributeXpWeights map', () {
      final result = calculator.calculate(
        attributeXpWeights: const {},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 0,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      );
      expect(result, isA<Err<QuestXpAllocation>>());
    });

    test('rejects completionRatio outside 0.0-1.0', () {
      final result = calculator.calculate(
        attributeXpWeights: {AttributeType.health: 10},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.5,
        consecutiveDayStreak: 0,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      );
      expect(result, isA<Err<QuestXpAllocation>>());
    });

    test('rejects qualityRating outside 1-5', () {
      final result = calculator.calculate(
        attributeXpWeights: {AttributeType.health: 10},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 0,
        qualityRating: 6,
        repeatIndexInOccurrence: 0,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      );
      expect(result, isA<Err<QuestXpAllocation>>());
    });

    test('rejects a negative repeatIndexInOccurrence', () {
      final result = calculator.calculate(
        attributeXpWeights: {AttributeType.health: 10},
        difficulty: QuestDifficulty.normal,
        completionRatio: 1.0,
        consecutiveDayStreak: 0,
        repeatIndexInOccurrence: -1,
        priorXpEarnedInOccurrence: 0,
        isFirstCompletionEver: false,
      );
      expect(result, isA<Err<QuestXpAllocation>>());
    });
  });
}
