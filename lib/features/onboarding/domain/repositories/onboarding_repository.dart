/// Local-only "has the user seen onboarding" flag. Every method is
/// synchronous — the underlying storage is a raw Hive `Box<bool>`, and
/// `Box` reads/writes never actually await anything once the box is open
/// (see `HiveOnboardingRepository`) — kept synchronous deliberately so the
/// router can gate its very first route decision without an async gap.
abstract interface class OnboardingRepository {
  bool isCompleted();

  void markCompleted();

  /// Used both by "Restart Onboarding" (Settings) and by "clear all local
  /// data" (which returns the whole app to first-run state).
  void reset();
}
