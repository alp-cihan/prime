import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/domain/services/quest_occurrence_policy.dart';

void main() {
  const policy = QuestOccurrencePolicy();

  group('occurrence keys', () {
    test('none always resolves to the fixed lifetime key', () {
      final a = policy.resolve(
        repeatability: Repeatability.none,
        instant: DateTime.utc(2026, 1, 10),
      );
      final b = policy.resolve(
        repeatability: Repeatability.none,
        instant: DateTime.utc(2031, 6, 30),
      );

      expect(a.key, QuestOccurrencePolicy.lifetimeOccurrenceKey);
      expect(b.key, QuestOccurrencePolicy.lifetimeOccurrenceKey);
    });

    test('daily: same calendar day (any time of day) shares one key', () {
      final morning = policy.resolve(
        repeatability: Repeatability.daily,
        instant: DateTime.utc(2026, 1, 10, 0, 1),
      );
      final night = policy.resolve(
        repeatability: Repeatability.daily,
        instant: DateTime.utc(2026, 1, 10, 23, 59),
      );

      expect(morning.key, '2026-01-10');
      expect(night.key, morning.key);
    });

    test('daily: crossing midnight is a new occurrence', () {
      final day1 = policy.resolve(
        repeatability: Repeatability.daily,
        instant: DateTime.utc(2026, 1, 10, 23, 59),
      );
      final day2 = policy.resolve(
        repeatability: Repeatability.daily,
        instant: DateTime.utc(2026, 1, 11, 0, 0),
      );

      expect(day1.key, isNot(day2.key));
      expect(day2.key, '2026-01-11');
    });

    test('weekly: every day Monday..Sunday shares one ISO week key', () {
      // 2026-01-05 is a Monday; 2026-01-11 is the following Sunday.
      final monday = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 5),
      );
      for (var day = 5; day <= 11; day++) {
        final resolved = policy.resolve(
          repeatability: Repeatability.weekly,
          instant: DateTime.utc(2026, 1, day),
        );
        expect(resolved.key, monday.key, reason: 'day $day');
        expect(resolved.anchorDate, DateTime.utc(2026, 1, 5));
      }
    });

    test('weekly: the following Monday is a new occurrence', () {
      final thisWeek = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 11), // Sunday
      );
      final nextWeek = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 12), // Monday
      );

      expect(thisWeek.key, isNot(nextWeek.key));
    });

    test('weekly: ISO week key format is YYYY-Www, zero-padded', () {
      final resolved = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 5), // 2026's first Monday -> W02
      );
      expect(resolved.key, matches(RegExp(r'^\d{4}-W\d{2}$')));
    });

    test('2026-01-01 (a Thursday, the year\'s first) is ISO week 2026-W01', () {
      final resolved = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 1),
      );
      expect(resolved.key, '2026-W01');
    });

    test('year transition: Dec 31 2026 and Jan 1 2027 share the same ISO week '
        '(2026-W53) — a new calendar year does not by itself start a new '
        'occurrence', () {
      final dec31 = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 12, 31), // Thursday
      );
      final jan1 = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2027, 1, 1), // Friday
      );

      expect(dec31.key, '2026-W53');
      expect(jan1.key, '2026-W53');
      expect(dec31.anchorDate, DateTime.utc(2026, 12, 28)); // Monday
      expect(jan1.anchorDate, DateTime.utc(2026, 12, 28));
    });

    test(
      'the following Monday (Jan 4 2027) is the genuine 2027-W01 occurrence',
      () {
        final resolved = policy.resolve(
          repeatability: Repeatability.weekly,
          instant: DateTime.utc(2027, 1, 4),
        );
        expect(resolved.key, '2027-W01');
        expect(resolved.anchorDate, DateTime.utc(2027, 1, 4));
      },
    );

    test(
      'a day late in the year can belong to next year\'s week 1 '
      '(Dec 31 2024 -> 2025-W01, since Jan 2 2025 is that week\'s Thursday)',
      () {
        final resolved = policy.resolve(
          repeatability: Repeatability.weekly,
          instant: DateTime.utc(2024, 12, 31),
        );
        expect(resolved.key, '2025-W01');
      },
    );
  });

  group('anchor dates', () {
    test('none: anchor is the instant itself, date-normalized', () {
      final resolved = policy.resolve(
        repeatability: Repeatability.none,
        instant: DateTime.utc(2026, 3, 15, 14, 30),
      );
      expect(resolved.anchorDate, DateTime.utc(2026, 3, 15));
    });

    test('daily: anchor is the instant itself, date-normalized', () {
      final resolved = policy.resolve(
        repeatability: Repeatability.daily,
        instant: DateTime.utc(2026, 3, 15, 14, 30),
      );
      expect(resolved.anchorDate, DateTime.utc(2026, 3, 15));
    });

    test('weekly: anchor is always that week\'s Monday', () {
      final sunday = policy.resolve(
        repeatability: Repeatability.weekly,
        instant: DateTime.utc(2026, 1, 11, 23, 0), // Sunday
      );
      expect(sunday.anchorDate, DateTime.utc(2026, 1, 5)); // Monday
    });
  });

  group('eligibility', () {
    test('none: eligible only while nothing has ever been earned', () {
      expect(
        policy.isEligible(
          repeatability: Repeatability.none,
          hasEverEarnedXp: false,
        ),
        isTrue,
      );
      expect(
        policy.isEligible(
          repeatability: Repeatability.none,
          hasEverEarnedXp: true,
        ),
        isFalse,
      );
    });

    test('daily/weekly: always eligible regardless of history', () {
      for (final repeatability in [Repeatability.daily, Repeatability.weekly]) {
        expect(
          policy.isEligible(
            repeatability: repeatability,
            hasEverEarnedXp: false,
          ),
          isTrue,
        );
        expect(
          policy.isEligible(
            repeatability: repeatability,
            hasEverEarnedXp: true,
          ),
          isTrue,
        );
      }
    });
  });

  group('reset decisions (isProgressStale)', () {
    test('none: progress is never stale, no matter how much time passed', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.none,
        storedAnchorDate: DateTime.utc(2020, 1, 1),
        instant: DateTime.utc(2030, 1, 1),
      );
      expect(stale, isFalse);
    });

    test('daily: same day is not stale', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.daily,
        storedAnchorDate: DateTime.utc(2026, 1, 10),
        instant: DateTime.utc(2026, 1, 10, 23, 0),
      );
      expect(stale, isFalse);
    });

    test('daily: crossing midnight makes stored progress stale', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.daily,
        storedAnchorDate: DateTime.utc(2026, 1, 10),
        instant: DateTime.utc(2026, 1, 11, 0, 1),
      );
      expect(stale, isTrue);
    });

    test('weekly: any day in the same ISO week is not stale', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.weekly,
        storedAnchorDate: DateTime.utc(2026, 1, 5), // Monday
        instant: DateTime.utc(2026, 1, 10), // Saturday, same week
      );
      expect(stale, isFalse);
    });

    test('weekly: the next ISO week makes stored progress stale', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.weekly,
        storedAnchorDate: DateTime.utc(2026, 1, 5), // Monday
        instant: DateTime.utc(2026, 1, 12), // next Monday
      );
      expect(stale, isTrue);
    });

    test('weekly: year transition does not falsely mark progress stale', () {
      final stale = policy.isProgressStale(
        repeatability: Repeatability.weekly,
        storedAnchorDate: DateTime.utc(2026, 12, 28), // Monday of 2026-W53
        instant: DateTime.utc(2027, 1, 1), // Friday, same ISO week
      );
      expect(stale, isFalse);
    });
  });
}
