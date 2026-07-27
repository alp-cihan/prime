/// Centralized, pure-Dart storage-key conventions shared by the Hive
/// repositories (to build/query box keys) and `CompleteQuestUseCase` (to
/// build `XpTransaction.sourceId`/`idempotencyKey`). Sharing one
/// implementation is deliberate: the use case *writes* using this date-key
/// format and the ledger repository *queries* by matching the same format
/// against `sourceId`'s prefix — if those two ever drifted independently,
/// `getTransactionsForQuestAndDate` would silently return the wrong rows.
///
/// This file has no dependency on `package:hive_ce` — it is plain string
/// formatting, safe to import from the application layer.
abstract final class HiveKeys {
  /// `yyyy-MM-dd` for an already UTC-date-normalized [DateTime].
  static String dateKey(DateTime normalizedDate) {
    final y = normalizedDate.year.toString().padLeft(4, '0');
    final m = normalizedDate.month.toString().padLeft(2, '0');
    final d = normalizedDate.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Box key for a `QuestProgress` row: unique per `(questId, date)`.
  static String questProgress(String questId, DateTime normalizedDate) =>
      '$questId|${dateKey(normalizedDate)}';

  /// Prefix shared by every `XpTransaction.sourceId` written for one
  /// `(questId, date)` — every attribute row of every completion that day.
  static String xpSourceIdDatePrefix(String questId, DateTime normalizedDate) =>
      '$questId|${dateKey(normalizedDate)}|';

  /// Prefix shared by every `XpTransaction.sourceId` ever written for
  /// [questId], across all dates — used to answer "has this quest ever
  /// earned XP" from the ledger itself (the only append-only, non-mutable
  /// history), rather than from `QuestProgress`, which is upserted per day
  /// and can be overwritten by a later progress decrement.
  static String xpSourceIdQuestPrefix(String questId) => '$questId|';

  /// Parses the date-key segment back out of an `XpTransaction.sourceId`
  /// (`"questId|dateKey|repeatIndex"`, see `CompleteQuestUseCase`) into the
  /// UTC `DateTime` it represents. Returns `null` if [sourceId] doesn't
  /// follow that shape — every writer in this codebase produces it, so this
  /// is only ever `null` for malformed/foreign data.
  static DateTime? dateFromSourceId(String sourceId) {
    final parts = sourceId.split('|');
    if (parts.length < 2) return null;
    final segments = parts[1].split('-');
    if (segments.length != 3) return null;
    final year = int.tryParse(segments[0]);
    final month = int.tryParse(segments[1]);
    final day = int.tryParse(segments[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }
}
