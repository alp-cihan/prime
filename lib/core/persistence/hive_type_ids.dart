/// Centralized, append-only registry of Hive CE `typeId`s used by
/// `@HiveType` model classes. **Never reuse or renumber an id once
/// assigned** — existing installs have already serialized data tagged with
/// these ids, and Hive resolves adapters by id, not by name. Add new
/// entries at the end with the next unused integer.
abstract final class HiveTypeIds {
  static const int quest = 0;
  static const int questProgress = 1;
  static const int xpTransaction = 2;
  static const int achievementUnlock = 3;
  static const int chainProgress = 4;
  static const int recommendationProfile = 5;

  /// Next id available for a future persisted model: 6.
}
