/// Testability seam for "now" — kept local to the quests application layer
/// since [CompleteQuestUseCase] is currently its only consumer. Promote to
/// `core/` if a second feature genuinely needs it.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
