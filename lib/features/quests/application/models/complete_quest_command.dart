/// Input to [CompleteQuestUseCase]. Only carries what genuinely comes from
/// the caller for *this* completion event — [progressValue] is what the
/// user logged, [qualityRating]/[notes]/[timeSpent] are optional context.
///
/// Deliberately absent: any notion of "repeat index," "prior XP today," or
/// "is this the first completion ever." Those are derived from ledger/
/// progress history inside the use case and must never be caller-supplied,
/// since a buggy or malicious caller could otherwise claim a false history
/// to inflate XP.
class CompleteQuestCommand {
  final String questId;
  final DateTime date;
  final double progressValue;
  final int? qualityRating;
  final String? notes;
  final Duration? timeSpent;

  const CompleteQuestCommand({
    required this.questId,
    required this.date,
    required this.progressValue,
    this.qualityRating,
    this.notes,
    this.timeSpent,
  });
}
