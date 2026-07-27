import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/services/quest_progress_policy.dart';

void main() {
  const policy = QuestProgressPolicy();

  group('binary', () {
    test('complete jumps straight to the target', () {
      final result = policy.nextValue(
        progressType: ProgressType.binary,
        operation: QuestProgressOperation.complete,
        currentValue: 0,
        targetValue: 1,
      );

      expect(result, isA<Ok<double>>());
      expect((result as Ok<double>).value, 1);
    });

    test('rejects increment', () {
      final result = policy.nextValue(
        progressType: ProgressType.binary,
        operation: QuestProgressOperation.increment,
        currentValue: 0,
        targetValue: 1,
      );

      expect(result, isA<Err<double>>());
      expect((result as Err<double>).failure, isA<ValidationFailure>());
    });

    test('rejects decrement', () {
      final result = policy.nextValue(
        progressType: ProgressType.binary,
        operation: QuestProgressOperation.decrement,
        currentValue: 1,
        targetValue: 1,
      );

      expect(result, isA<Err<double>>());
    });
  });

  group('quantity increment', () {
    test('increments by the given amount', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.increment,
        currentValue: 2,
        targetValue: 8,
        amount: 1,
      );

      expect((result as Ok<double>).value, 3);
    });

    test('clamps to the target rather than overshooting', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.increment,
        currentValue: 7,
        targetValue: 8,
        amount: 5,
      );

      expect((result as Ok<double>).value, 8);
    });

    test('incrementing while already at target stays at target', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.increment,
        currentValue: 8,
        targetValue: 8,
        amount: 1,
      );

      expect((result as Ok<double>).value, 8);
    });

    test('rejects a zero amount', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.increment,
        currentValue: 0,
        targetValue: 8,
        amount: 0,
      );

      expect(result, isA<Err<double>>());
      expect((result as Err<double>).failure, isA<ValidationFailure>());
    });

    test('rejects a negative amount', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.increment,
        currentValue: 0,
        targetValue: 8,
        amount: -1,
      );

      expect(result, isA<Err<double>>());
    });

    test('rejects direct completion', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.complete,
        currentValue: 0,
        targetValue: 8,
      );

      expect(result, isA<Err<double>>());
    });
  });

  group('quantity decrement', () {
    test('decrements by the given amount', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.decrement,
        currentValue: 5,
        targetValue: 8,
        amount: 2,
      );

      expect((result as Ok<double>).value, 3);
    });

    test('never goes below zero', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.decrement,
        currentValue: 1,
        targetValue: 8,
        amount: 5,
      );

      expect((result as Ok<double>).value, 0);
    });

    test('decrementing from zero stays at zero', () {
      final result = policy.nextValue(
        progressType: ProgressType.quantity,
        operation: QuestProgressOperation.decrement,
        currentValue: 0,
        targetValue: 8,
        amount: 1,
      );

      expect((result as Ok<double>).value, 0);
    });
  });

  group('duration', () {
    test('increments in minutes and clamps to target', () {
      final result = policy.nextValue(
        progressType: ProgressType.duration,
        operation: QuestProgressOperation.increment,
        currentValue: 25,
        targetValue: 30,
        amount: 10,
      );

      expect((result as Ok<double>).value, 30);
    });

    test('decrements in minutes and floors at zero', () {
      final result = policy.nextValue(
        progressType: ProgressType.duration,
        operation: QuestProgressOperation.decrement,
        currentValue: 3,
        targetValue: 30,
        amount: 5,
      );

      expect((result as Ok<double>).value, 0);
    });
  });

  group('isTargetReached', () {
    test('false below target', () {
      expect(policy.isTargetReached(5, 8), isFalse);
    });

    test('true exactly at target', () {
      expect(policy.isTargetReached(8, 8), isTrue);
    });

    test('true above target (defensive — nextValue never produces this)', () {
      expect(policy.isTargetReached(9, 8), isTrue);
    });
  });
}
