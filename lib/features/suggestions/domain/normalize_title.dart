/// Canonical quest-title normalization shared by `SuggestionRankingPolicy`
/// (to exclude suggestions matching an existing quest) and
/// `CreateQuestFromSuggestionUseCase` (to detect that match precisely
/// before creating) — a single implementation so the two can never drift
/// and disagree on what counts as "the same title."
String normalizeQuestTitle(String title) =>
    title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
