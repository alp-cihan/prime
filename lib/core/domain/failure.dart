/// Base type for domain-level failures. Subtypes are added only once a
/// concrete use of them exists — see docs/architecture.md's XP economy
/// section for why over-eager schema/type growth is avoided.
sealed class Failure {
  final String message;

  const Failure(this.message);
}

/// A domain rule was violated by the given input (as opposed to a missing
/// entity or a storage failure — those failure types are introduced in the
/// milestones that first need them).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
