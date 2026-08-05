/// Centralized Hive CE box names. One box per persisted entity type.
abstract final class HiveBoxNames {
  static const String quests = 'quests';
  static const String questProgress = 'quest_progress';
  static const String xpTransactions = 'xp_transactions';
  static const String achievementUnlocks = 'achievement_unlocks';
  static const String chainProgress = 'chain_progress';

  /// Phase 16 — single-record box holding the local recommendation
  /// profile (life stage/goals/time/intensity) plus accepted suggestion ids.
  static const String recommendationProfile = 'recommendation_profile';

  /// Untyped `Box<bool>` holding small app-level flags (currently just
  /// onboarding completion) — no `@HiveType` model needed for a single
  /// boolean, so this deliberately doesn't get a `HiveTypeIds` entry.
  static const String appPreferences = 'app_preferences';

  /// Every box name Prime owns — the single source of truth for "clear all
  /// local data" (Settings), so that operation can never miss a box or
  /// accidentally touch storage outside the app's own boxes.
  static const List<String> all = [
    quests,
    questProgress,
    xpTransactions,
    achievementUnlocks,
    chainProgress,
    recommendationProfile,
    appPreferences,
  ];
}
