/// Prime Asset Pack v0.1 — resolves a [QuestVisual] `seed` (a quest id, or a
/// suggestion `visualKey` in the `'<category>/<slug>'` shape documented on
/// `QuestSuggestion.visualKey`) to a bundled illustration, when one exists
/// for that category. Presentation-only: no domain/provider/repository code
/// reads or depends on this — `QuestVisual` is the single call site, so
/// swapping or growing the asset pack never touches a call site.
///
/// A `seed` with no recognizable category (e.g. a plain quest id, which
/// carries no category information at all) intentionally resolves to
/// `null` — `QuestVisual` then keeps rendering today's gradient
/// placeholder, exactly as documented on [resolve].
class AssetVisualResolver {
  const AssetVisualResolver();

  static const _basePath = 'assets/visuals';

  /// One category → its available illustration variants. v0.1 ships exactly
  /// one file per category; adding `fitness_02.png` etc. later is a pure
  /// data change here — [resolve] already picks deterministically among
  /// however many variants a category has (see [_pick]), so no call site
  /// or caller needs to change when variants are added.
  static const Map<String, List<String>> _variantsByCategory = {
    'fitness': ['$_basePath/fitness.png'],
    'coding': ['$_basePath/coding.png'],
    'reading': ['$_basePath/reading.png'],
    'meditation': ['$_basePath/meditation.png'],
    'running': ['$_basePath/running.png'],
    'walking': ['$_basePath/walking.png'],
    'study': ['$_basePath/study.png'],
    'journaling': ['$_basePath/journaling.png'],
    'water': ['$_basePath/water.png'],
    'nutrition': ['$_basePath/nutrition.png'],
    'sleep': ['$_basePath/sleep.png'],
    'cleaning': ['$_basePath/cleaning.png'],
  };

  /// Maps a token found in a `seed` to one of [_variantsByCategory]'s keys.
  /// Includes each category's own name (identity) plus a short, explicit
  /// list of synonyms actually present in today's suggestion catalog (e.g.
  /// `fitness/walk_20`, `organization/declutter`) — exact-token matching
  /// only, deliberately no fuzzy/substring matching, so a mismatch is never
  /// silently "close enough."
  static const Map<String, String> _categoryAliases = {
    'fitness': 'fitness',
    'coding': 'coding',
    'reading': 'reading',
    'meditation': 'meditation',
    'running': 'running',
    'walking': 'walking',
    'study': 'study',
    'journaling': 'journaling',
    'water': 'water',
    'nutrition': 'nutrition',
    'sleep': 'sleep',
    'cleaning': 'cleaning',
    'walk': 'walking',
    'run': 'running',
    'clean': 'cleaning',
    'tidy': 'cleaning',
    'declutter': 'cleaning',
    'journal': 'journaling',
    'meditate': 'meditation',
    'mindfulness': 'meditation',
    'code': 'coding',
    'programming': 'coding',
  };

  /// Returns a deterministic asset path for [seed], or `null` if nothing in
  /// the pack matches. Checks, in order (most specific first): the slug's
  /// own `_`-separated tokens, the whole slug, then the category segment —
  /// so `nutrition/water` resolves to `water.png` (the more specific match)
  /// rather than the generic `nutrition.png`, while `study/pomodoro` falls
  /// through to `study.png` via its category segment.
  String? resolve(String seed) {
    final segments = seed
        .toLowerCase()
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    if (segments.isEmpty) return null;

    final slug = segments.length > 1 ? segments.last : null;
    final candidateTokens = <String>[
      ...?slug?.split('_'),
      ?slug,
      segments.first,
    ];

    for (final token in candidateTokens) {
      final category = _categoryAliases[token];
      final variants = category == null ? null : _variantsByCategory[category];
      if (variants != null && variants.isNotEmpty) {
        return _pick(variants, seed);
      }
    }
    return null;
  }

  /// Deterministic (never random) pick among a category's variants — same
  /// hash-based approach as `AppGradients.questPlaceholder`, so the same
  /// [seed] always resolves to the same illustration.
  String _pick(List<String> variants, String seed) {
    if (variants.length == 1) return variants.first;
    return variants[seed.hashCode.abs() % variants.length];
  }
}
