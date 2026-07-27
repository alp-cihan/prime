import '../../../../core/persistence/hive_keys.dart';
import '../../../xp_ledger/domain/repositories/xp_ledger_repository.dart';
import '../../domain/entities/quest.dart';
import '../../domain/services/quest_occurrence_policy.dart';

/// Everything [CompleteQuestUseCase] needs to know about the occurrence a
/// completion at a given instant falls into: its identity/anchor date
/// ([occurrence]), whether it's allowed to pay out at all ([eligible]),
/// where it sits in the diminishing-returns sequence ([repeatIndex]), how
/// much XP this quest has already earned in the same occurrence
/// ([priorXpEarnedInOccurrence], feeding the daily-cap clamp), and whether
/// this would be the quest's first completion ever ([isFirstCompletionEver],
/// feeding the first-completion bonus).
class QuestOccurrenceStatus {
  final QuestOccurrence occurrence;
  final bool eligible;
  final bool isFirstCompletionEver;
  final int repeatIndex;
  final int priorXpEarnedInOccurrence;

  const QuestOccurrenceStatus({
    required this.occurrence,
    required this.eligible,
    required this.isFirstCompletionEver,
    required this.repeatIndex,
    required this.priorXpEarnedInOccurrence,
  });
}

/// Composes [QuestOccurrencePolicy] with the XP ledger to answer "what is
/// this quest's occurrence status right now" — the one place
/// [CompleteQuestUseCase] goes for eligibility/repeat-index/first-completion
/// facts, replacing the ad hoc ledger reads that use case used to do
/// directly (see its Phase 8 history). `QuestProgressRepository` is
/// deliberately not a dependency here: eligibility and repeat index must
/// never be derived from `QuestProgress` (CLAUDE.md/Phase 9 spec — progress
/// is mutable display state, the ledger is the append-only source of
/// truth), and the current occurrence's *anchor date* — the only thing a
/// caller needs to read/write `QuestProgress` correctly — comes straight off
/// [QuestOccurrencePolicy.resolve] without needing this class at all (see
/// `UpdateQuestProgressUseCase`, which depends on the policy directly for
/// exactly that reason).
///
/// ## Why there is no persisted "current occurrence" or reset write
/// Every fact this class produces is recomputed from the ledger and the
/// instant it's given — nothing about occurrence membership is ever stored.
/// A quest's `QuestProgress` row is keyed by [QuestOccurrence.anchorDate],
/// so a new occurrence's anchor is, by construction, a key nothing has ever
/// written to: reading it back naturally returns "no progress yet" without
/// any explicit reset step, background job, or stale-data cleanup. This is
/// the derivation-over-persistence design the Phase 9 spec asks for
/// ("if occurrence can always be derived safely from ledger + clock, prefer
/// derivation") — see `QuestOccurrencePolicy.isProgressStale` for the
/// explicit, directly-tested definition of what a reset *would* detect, kept
/// for documentation/testing purposes even though production code never
/// needs to call it.
class QuestOccurrenceService {
  const QuestOccurrenceService({
    required XpLedgerRepository xpLedgerRepository,
    QuestOccurrencePolicy policy = const QuestOccurrencePolicy(),
  }) : _xpLedgerRepository = xpLedgerRepository,
       _policy = policy;

  final XpLedgerRepository _xpLedgerRepository;
  final QuestOccurrencePolicy _policy;

  Future<QuestOccurrenceStatus> resolve({
    required Quest quest,
    required DateTime instant,
  }) async {
    final occurrence = _policy.resolve(
      repeatability: quest.repeatability,
      instant: instant,
    );

    // The full lifetime ledger for this quest — never a single day/week's
    // slice — because membership in the *current* occurrence has to be
    // recomputed per entry (each entry's own date-key segment resolves to
    // its own occurrence, which may or may not match the current one), not
    // assumed from how the row happens to be indexed.
    final allTransactions = await _xpLedgerRepository.getTransactionsForQuest(
      quest.id,
    );

    final sourceIdsInOccurrence = <String>{};
    var priorXpEarnedInOccurrence = 0;
    for (final transaction in allTransactions) {
      final entryDate = HiveKeys.dateFromSourceId(transaction.sourceId);
      if (entryDate == null) continue;
      final entryOccurrence = _policy.resolve(
        repeatability: quest.repeatability,
        instant: entryDate,
      );
      if (entryOccurrence.key == occurrence.key) {
        sourceIdsInOccurrence.add(transaction.sourceId);
        priorXpEarnedInOccurrence += transaction.finalXp;
      }
    }

    return QuestOccurrenceStatus(
      occurrence: occurrence,
      eligible: _policy.isEligible(
        repeatability: quest.repeatability,
        hasEverEarnedXp: allTransactions.isNotEmpty,
      ),
      isFirstCompletionEver: allTransactions.isEmpty,
      repeatIndex: sourceIdsInOccurrence.length,
      priorXpEarnedInOccurrence: priorXpEarnedInOccurrence,
    );
  }
}
