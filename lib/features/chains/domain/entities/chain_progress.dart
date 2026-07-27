/// The persisted, mutable progress record for one [Chain] — the *only*
/// chain-related state this app ever stores (chain definitions themselves
/// stay code-based).
///
/// [completedStageCount] is the single authoritative field: how many
/// leading stages (0-based, in [Chain.questIds] order) have been completed
/// so far. Every other "tracked" concept `ChainProgressPolicy` exposes —
/// unlocked-stage count, current stage index, completion percentage — is
/// *derived* from this one number plus the chain's own `questIds.length`,
/// rather than stored redundantly (CLAUDE.md: "Cached... totals are
/// projections, not the source of truth" applies here just as it does to
/// the XP ledger's derived totals).
///
/// [completedAt] is `null` until [completedStageCount] reaches
/// `chain.questIds.length`, and is set exactly once at that transition —
/// it is also the idempotency gate `EvaluateAndAdvanceChainsUseCase` checks
/// before ever re-evaluating a chain, so "duplicate completion must be
/// impossible" holds by construction: once non-null, this record is never
/// advanced or rewarded again.
class ChainProgress {
  final String chainId;
  final int completedStageCount;
  final DateTime? completedAt;

  const ChainProgress({
    required this.chainId,
    required this.completedStageCount,
    this.completedAt,
  });

  @override
  bool operator ==(Object other) =>
      other is ChainProgress &&
      other.chainId == chainId &&
      other.completedStageCount == completedStageCount &&
      other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(chainId, completedStageCount, completedAt);
}
