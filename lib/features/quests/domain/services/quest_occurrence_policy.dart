import '../entities/repeatability.dart';

/// One resolved occurrence: the identity a completion (or a progress read)
/// at a given instant belongs to, plus the date [QuestProgress] rows should
/// be keyed by for that occurrence.
///
/// [anchorDate] is deliberately not always "the day this happened": for
/// `weekly` quests it is the Monday of the ISO week containing the instant,
/// so every mutation during that week resolves to the exact same
/// `QuestProgress` row (`questId`, `anchorDate`) and a new week's Monday is,
/// by construction, a fresh/empty row — this is the whole reset mechanism
/// (see `QuestOccurrenceService`'s class doc for why no explicit
/// reset-and-persist step is needed anywhere).
class QuestOccurrence {
  final String key;
  final DateTime anchorDate;

  const QuestOccurrence({required this.key, required this.anchorDate});

  @override
  bool operator ==(Object other) =>
      other is QuestOccurrence &&
      other.key == key &&
      other.anchorDate == anchorDate;

  @override
  int get hashCode => Object.hash(key, anchorDate);

  @override
  String toString() => 'QuestOccurrence($key, $anchorDate)';
}

/// Phase 9 — the single authority for occurrence boundaries: what
/// occurrence a [Repeatability] quest is currently in, whether it is
/// eligible to be completed, and whether previously-recorded progress has
/// gone stale. Pure Dart, no Flutter/Hive/Riverpod imports, and no
/// `DateTime.now()` of its own — every method takes the instant it should
/// reason about as a parameter, so callers stay in control of "now" (via
/// `Clock`, in the application layer) and every decision here is a pure
/// function of its inputs, trivially testable with fixed dates.
///
/// Deliberately ignorant of `XpTransaction`/the XP ledger: counting how many
/// prior ledger entries fall inside an occurrence (the "repeat index") needs
/// ledger access this pure domain policy must not have — that composition
/// lives in `QuestOccurrenceService` (application layer). This class only
/// ever answers "what occurrence is this", "is that occurrence allowed to
/// pay out at all", and "has stored progress fallen behind".
class QuestOccurrencePolicy {
  const QuestOccurrencePolicy();

  /// A one-time quest has exactly one occurrence for its entire lifetime —
  /// this key never varies with the clock.
  static const lifetimeOccurrenceKey = 'lifetime';

  /// Resolves the occurrence [instant] belongs to for [repeatability]:
  /// - `none`: the fixed lifetime occurrence. [QuestOccurrence.anchorDate]
  ///   is [instant] itself (date-normalized) purely so a `QuestProgress` row
  ///   still has a date to be keyed by — it is never compared against a
  ///   later instant's anchor (see [isProgressStale]: one-time progress is
  ///   never stale).
  /// - `daily`: one occurrence per UTC calendar date (`YYYY-MM-DD`).
  /// - `weekly`: one occurrence per ISO-8601 week, Monday-first
  ///   (`YYYY-Www`); [QuestOccurrence.anchorDate] is that week's Monday.
  QuestOccurrence resolve({
    required Repeatability repeatability,
    required DateTime instant,
  }) {
    final date = _normalizeDate(instant);
    return switch (repeatability) {
      Repeatability.none => QuestOccurrence(
        key: lifetimeOccurrenceKey,
        anchorDate: date,
      ),
      Repeatability.daily => QuestOccurrence(
        key: _dayKey(date),
        anchorDate: date,
      ),
      Repeatability.weekly => QuestOccurrence(
        key: _isoWeekKey(date),
        anchorDate: _mondayOf(date),
      ),
    };
  }

  /// Whether a completion is allowed to earn XP at all, given whether the
  /// ledger has **ever** recorded a prior completion for this quest.
  ///
  /// `none`: eligible only while the ledger has never paid out — there is
  /// only ever one occurrence to exhaust, for the quest's whole lifetime.
  /// `daily`/`weekly`: always eligible — repeats within one occurrence are
  /// priced down by diminishing returns (docs/architecture.md §3.3), never
  /// blocked outright.
  bool isEligible({
    required Repeatability repeatability,
    required bool hasEverEarnedXp,
  }) {
    if (repeatability == Repeatability.none) return !hasEverEarnedXp;
    return true;
  }

  /// Whether progress recorded under [storedAnchorDate] is stale relative to
  /// [instant] — i.e. a new occurrence has begun and that stored value no
  /// longer applies. One-time quests are never stale (§ "One-time quests:
  /// never reset automatically") — their single occurrence's progress is
  /// permanent, regardless of how much time has passed.
  ///
  /// This is the authoritative definition of "reset decision", but nothing
  /// in the application needs to call it to make resets happen: every
  /// caller always re-resolves the *current* anchor via [resolve] before
  /// touching `QuestProgress`, so a stale row is simply never read again —
  /// see `QuestOccurrenceService`'s class doc. It is kept as an explicit,
  /// directly-testable function because "what counts as stale" is exactly
  /// the kind of boundary decision that deserves its own unit tests
  /// independent of how the rest of the app happens to avoid needing it.
  bool isProgressStale({
    required Repeatability repeatability,
    required DateTime storedAnchorDate,
    required DateTime instant,
  }) {
    if (repeatability == Repeatability.none) return false;
    final current = resolve(repeatability: repeatability, instant: instant);
    return _normalizeDate(storedAnchorDate) != current.anchorDate;
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Monday of the ISO week containing [date]. `DateTime.weekday` is
  /// `1`(Monday)..`7`(Sunday), so subtracting `weekday - 1` days always
  /// lands on that week's Monday.
  DateTime _mondayOf(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  /// ISO-8601 week key `YYYY-Www`. Uses the standard "Thursday trick": the
  /// Thursday of a week determines both that week's ISO week-year (a week
  /// belongs to the year containing its Thursday, so the last days of
  /// December can belong to week 1 of the next year and vice versa) and,
  /// via its distance from that year's January 1st, the week number itself
  /// — week 1 is, by definition, the week containing the year's first
  /// Thursday, and this formula produces that without a special case.
  String _isoWeekKey(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final isoYear = thursday.year;
    final jan1 = DateTime.utc(isoYear, 1, 1);
    final week = (thursday.difference(jan1).inDays ~/ 7) + 1;
    final y = isoYear.toString().padLeft(4, '0');
    final w = week.toString().padLeft(2, '0');
    return '$y-W$w';
  }
}
