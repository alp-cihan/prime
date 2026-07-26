import 'failure.dart';

/// Outcome of a fallible domain operation: either a success value or a
/// [Failure]. Kept as a plain sealed class — no external package — so the
/// domain layer stays pure Dart.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
