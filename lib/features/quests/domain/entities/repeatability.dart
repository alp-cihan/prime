/// Phase 9 — replaces the loosely-typed `String? repeatabilityRule` with an
/// explicit, exhaustive occurrence cadence. `none` is the one-time case
/// (docs/architecture.md's field with no rule at all, previously `null`).
/// `monthly`/custom-cron cadences mentioned in docs/architecture.md §15 are
/// deliberately out of scope for this phase (see the Phase 9 non-goals) —
/// nothing in the application can select or produce them.
enum Repeatability { none, daily, weekly }
