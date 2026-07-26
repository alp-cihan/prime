import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/quests/data/mappers/quest_progress_mapper.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';

void main() {
  const mapper = QuestProgressMapper();

  test('round-trips every currently persisted field', () {
    final progress = QuestProgress(
      questId: 'q1',
      date: DateTime.utc(2026, 1, 10),
      progressValue: 45,
      isComplete: false,
      notes: 'felt tired but pushed through',
      qualityRating: 4,
      timeSpent: const Duration(minutes: 45, seconds: 30),
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));
    expect(roundTripped, progress);
  });

  test('round-trips when every nullable field is null', () {
    final progress = QuestProgress(
      questId: 'q1',
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
      isComplete: true,
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));
    expect(roundTripped, progress);
    expect(roundTripped.notes, isNull);
    expect(roundTripped.qualityRating, isNull);
    expect(roundTripped.timeSpent, isNull);
  });

  test('date is normalized to UTC date-only and survives the round trip', () {
    final progress = QuestProgress(
      questId: 'q1',
      date: DateTime.utc(2026, 6, 15),
      progressValue: 1,
      isComplete: true,
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));
    expect(roundTripped.date, DateTime.utc(2026, 6, 15));
    expect(roundTripped.date.isUtc, isTrue);
  });

  test('Duration survives the round trip to microsecond precision', () {
    const timeSpent = Duration(
      hours: 1,
      minutes: 2,
      seconds: 3,
      milliseconds: 4,
    );
    final progress = QuestProgress(
      questId: 'q1',
      date: DateTime.utc(2026, 1, 10),
      progressValue: 1,
      isComplete: true,
      timeSpent: timeSpent,
    );

    final roundTripped = mapper.toDomain(mapper.toModel(progress));
    expect(roundTripped.timeSpent, timeSpent);
  });
}
