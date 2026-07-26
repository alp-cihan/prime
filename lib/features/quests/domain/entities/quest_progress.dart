/// A single day's completion log for a [Quest]. docs/architecture.md §15/§17
/// — append-only per date, idempotent by `(questId, date)`.
class QuestProgress {
  final String questId;
  final DateTime date;
  final double progressValue;
  final bool isComplete;
  final String? notes;
  final int? qualityRating;
  final Duration? timeSpent;

  const QuestProgress({
    required this.questId,
    required this.date,
    required this.progressValue,
    required this.isComplete,
    this.notes,
    this.qualityRating,
    this.timeSpent,
  });

  QuestProgress copyWith({
    String? questId,
    DateTime? date,
    double? progressValue,
    bool? isComplete,
    String? notes,
    int? qualityRating,
    Duration? timeSpent,
  }) {
    return QuestProgress(
      questId: questId ?? this.questId,
      date: date ?? this.date,
      progressValue: progressValue ?? this.progressValue,
      isComplete: isComplete ?? this.isComplete,
      notes: notes ?? this.notes,
      qualityRating: qualityRating ?? this.qualityRating,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is QuestProgress &&
      other.questId == questId &&
      other.date == date &&
      other.progressValue == progressValue &&
      other.isComplete == isComplete &&
      other.notes == notes &&
      other.qualityRating == qualityRating &&
      other.timeSpent == timeSpent;

  @override
  int get hashCode => Object.hash(
    questId,
    date,
    progressValue,
    isComplete,
    notes,
    qualityRating,
    timeSpent,
  );
}
