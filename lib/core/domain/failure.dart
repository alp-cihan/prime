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

/// The requested entity does not exist. First used by
/// `CompleteQuestUseCase` (Phase 2) to reject a missing quest.
///
/// This lives here rather than under `features/quests/application/` because
/// [Failure] is `sealed`: Dart only allows direct subtypes of a sealed class
/// within the same library (file), so any type that needs to be a genuine
/// `Failure` variant — enabling exhaustive `switch` handling — must be
/// declared alongside it. Splitting operation-specific failures into their
/// own feature-owned file would require either a `part`/`part of` link back
/// into `core/domain` (an inverted, feature-into-core dependency) or
/// widening `Failure` from `sealed` to `abstract` (losing exhaustiveness
/// checking for every existing caller). Keeping the file as the single
/// source for all `Failure` variants avoids both.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// An operation was attempted on an entity whose current state does not
/// permit it (e.g. completing an expired or converted quest). First used by
/// `CompleteQuestUseCase` (Phase 2). See [NotFoundFailure] for why
/// operation-specific failures live in this file.
final class InvalidStateFailure extends Failure {
  const InvalidStateFailure(super.message);
}
