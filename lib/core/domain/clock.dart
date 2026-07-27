/// Testability seam for "now" — promoted here from the quests feature
/// (Phase 9) once achievements (Phase 10) became a second, genuinely
/// independent consumer. Pure Dart, no Flutter/Hive/Riverpod imports.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  // UTC, not local: every other DateTime in this codebase (normalized
  // completion dates, persisted timestamps) is UTC. Dart's `DateTime.==`
  // requires both the same instant *and* the same zone flag, so a local
  // `createdAt` would silently stop comparing equal to itself after a
  // round trip through Hive persistence (which always reconstructs as
  // UTC — see the xp_ledger data mappers). Keeping this UTC avoids that.
  @override
  DateTime now() => DateTime.now().toUtc();
}
