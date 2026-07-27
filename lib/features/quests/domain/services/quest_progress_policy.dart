import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../entities/quest.dart';

/// The three ways [QuestProgressPolicy.nextValue] can be asked to move a
/// quest's progress. `complete` is binary-only (jumps straight to the
/// target); `increment`/`decrement` are quantity/duration-only.
enum QuestProgressOperation { increment, decrement, complete }

/// Single authority for quest-progress arithmetic — docs/architecture.md
/// §5.2's `ProgressType` (binary/quantity/duration) governs which
/// [QuestProgressOperation]s are valid and how a new value is derived.
/// Widgets and use cases both defer to this; neither performs the
/// arithmetic itself.
///
/// ## Duration's unit
/// Nothing in the existing domain model (`Quest.targetProgress`,
/// `QuestProgress.progressValue` — both plain `double`) establishes a unit
/// for duration quests. This phase fixes it as **integer minutes** stored in
/// that same `double` field (e.g. `targetProgress: 30.0` means "30
/// minutes") — the smallest change consistent with "prefer integer minutes
/// unless the domain already establishes another unit." `QuestProgress
/// .timeSpent` (a `Duration?`) is a separate, already-existing field for a
/// single session's length and is untouched by this policy.
///
/// ## Clamping
/// Increment/decrement results are always clamped to `[0, targetValue]` —
/// per this phase's explicit preference over any other overflow rule. A
/// value can never be pushed below zero or past the target no matter how
/// large [amount] is.
class QuestProgressPolicy {
  const QuestProgressPolicy();

  Result<double> nextValue({
    required ProgressType progressType,
    required QuestProgressOperation operation,
    required double currentValue,
    required double targetValue,
    double amount = 1,
  }) {
    switch (progressType) {
      case ProgressType.binary:
        if (operation != QuestProgressOperation.complete) {
          return const Err(
            ValidationFailure(
              'Binary quests only support the complete operation.',
            ),
          );
        }
        return Ok(targetValue);

      case ProgressType.quantity:
      case ProgressType.duration:
        if (operation == QuestProgressOperation.complete) {
          return const Err(
            ValidationFailure(
              'Quantity/duration quests complete automatically when the '
              'target is reached — increment toward it instead.',
            ),
          );
        }
        if (amount <= 0) {
          return const Err(
            ValidationFailure('Amount must be greater than zero.'),
          );
        }
        final delta = operation == QuestProgressOperation.increment
            ? amount
            : -amount;
        final raw = currentValue + delta;
        return Ok(raw.clamp(0.0, targetValue));
    }
  }

  /// `>=` rather than `==` — [nextValue] already clamps to at most
  /// [targetValue], but this stays a safe, order-independent check for any
  /// caller working from a value it didn't get from [nextValue] itself.
  bool isTargetReached(double value, double targetValue) =>
      value >= targetValue;
}
