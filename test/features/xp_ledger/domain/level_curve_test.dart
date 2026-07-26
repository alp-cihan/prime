import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/xp_ledger/domain/services/level_curve.dart';

void main() {
  const curve = LevelCurve();

  group('xpToNext', () {
    test(
      'matches the docs/architecture.md §4.1 reference table for base 100',
      () {
        expect(curve.xpToNext(1, base: 100), 100);
        expect(curve.xpToNext(5, base: 100), 1118);
        expect(curve.xpToNext(10, base: 100), 3162);
        expect(curve.xpToNext(20, base: 100), 8944);
        expect(curve.xpToNext(30, base: 100), 16431);
        expect(curve.xpToNext(50, base: 100), 35355);
        expect(curve.xpToNext(100, base: 100), 100000);
      },
    );

    test('scales with a different base (attribute curve, base 30)', () {
      expect(curve.xpToNext(1, base: 30), 30);
      expect(
        curve.xpToNext(10, base: 30),
        (curve.xpToNext(10, base: 100) * 0.3).floor(),
      );
    });

    test('is monotonically non-decreasing', () {
      for (var level = 1; level < 100; level++) {
        expect(
          curve.xpToNext(level + 1, base: 100),
          greaterThanOrEqualTo(curve.xpToNext(level, base: 100)),
        );
      }
    });
  });

  group('levelForTotalXp', () {
    test('agrees with cumulativeXpForLevel at exact level boundaries', () {
      for (final level in [1, 2, 5, 10, 20, 30, 50]) {
        final cumulative = curve.cumulativeXpForLevel(level, base: 100);
        final progress = curve.levelForTotalXp(cumulative, base: 100);
        expect(progress.level, level);
        expect(progress.currentXpIntoLevel, 0);
        expect(
          progress.xpRequiredForNextLevel,
          curve.xpToNext(level, base: 100),
        );
      }
    });

    test('reports partial progress into the next level', () {
      final cumulativeAtLevel10 = curve.cumulativeXpForLevel(10, base: 100);
      final progress = curve.levelForTotalXp(
        cumulativeAtLevel10 + 500,
        base: 100,
      );
      expect(progress.level, 10);
      expect(progress.currentXpIntoLevel, 500);
    });

    test('starts at level 1 with zero XP', () {
      final progress = curve.levelForTotalXp(0, base: 100);
      expect(progress.level, 1);
      expect(progress.currentXpIntoLevel, 0);
      expect(progress.xpRequiredForNextLevel, 100);
    });

    test(
      'rejects a negative totalXp instead of looping or returning invalid progress',
      () {
        expect(() => curve.levelForTotalXp(-1, base: 100), throwsArgumentError);
      },
    );
  });

  group('invalid input contracts', () {
    test('xpToNext rejects base <= 0', () {
      expect(() => curve.xpToNext(1, base: 0), throwsArgumentError);
      expect(() => curve.xpToNext(1, base: -10), throwsArgumentError);
    });

    test('xpToNext rejects level < 1', () {
      expect(() => curve.xpToNext(0, base: 100), throwsArgumentError);
      expect(() => curve.xpToNext(-5, base: 100), throwsArgumentError);
    });

    test('cumulativeXpForLevel rejects base <= 0', () {
      expect(() => curve.cumulativeXpForLevel(5, base: 0), throwsArgumentError);
      expect(
        () => curve.cumulativeXpForLevel(5, base: -1),
        throwsArgumentError,
      );
    });

    test('levelForTotalXp rejects base <= 0 without looping', () {
      expect(() => curve.levelForTotalXp(100, base: 0), throwsArgumentError);
      expect(() => curve.levelForTotalXp(100, base: -1), throwsArgumentError);
    });
  });
}
