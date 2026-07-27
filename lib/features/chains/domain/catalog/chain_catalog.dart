import '../entities/chain.dart';

/// Phase 11's built-in, code-defined chain catalog — the single source of
/// truth for every chain, mirroring `achievement_catalog.dart`'s pattern.
///
/// Deliberately empty: a [Chain] references real `Quest.id` values (in
/// completion order), and this app has no fixed, always-present onboarding
/// quests yet for a compile-time chain to point at — every quest today is
/// user-created, so its id can't be known ahead of time. The full mechanism
/// (domain policy, application evaluation/advancement, persistence,
/// providers, UI) is implemented and tested against chains constructed in
/// tests; this constant is the single place a future release would add
/// real entries once fixed onboarding content exists, exactly the
/// extensibility point the Phase 11 brief asks for ("future story
/// campaigns and boss prerequisites").
const chainCatalog = <Chain>[];
