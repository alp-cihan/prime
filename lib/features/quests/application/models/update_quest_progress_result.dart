import 'complete_quest_result.dart';

/// Outcome of a successful [UpdateQuestProgressUseCase] run. [completed] is
/// true only when *this* mutation was the one that newly crossed the
/// target — a subsequent no-op increment while already at target reports
/// `completed: false`, since nothing new happened. [completionResult] is
/// only non-null when [completed] is true — it is exactly what
/// [CompleteQuestUseCase] returned for that crossing (the sole XP-awarding
/// authority; this use case never computes XP itself).
class UpdateQuestProgressResult {
  final double previousProgress;
  final double newProgress;
  final bool completed;
  final CompleteQuestResult? completionResult;

  const UpdateQuestProgressResult({
    required this.previousProgress,
    required this.newProgress,
    required this.completed,
    this.completionResult,
  });
}
