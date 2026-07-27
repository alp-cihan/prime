/// Route path constants — single source of truth for navigation targets.
abstract final class AppRoutes {
  static const String today = '/';
  static const String quests = '/quests';
  static const String story = '/story';
  static const String journal = '/journal';
  static const String you = '/you';
  static const String focus = '/focus';

  /// Path segment for the achievements gallery, nested under [you] — per
  /// docs/architecture.md §19 ("/achievements ... pushed from within the You
  /// tab, not separate shell destinations — keeps nav count at 5").
  static const String achievementsSegment = 'achievements';

  /// Builds the concrete path to the achievements gallery.
  static String achievements = '$you/$achievementsSegment';

  /// Path segment for the chains gallery, nested under [you] — same
  /// placement rationale as [achievementsSegment].
  static const String chainsSegment = 'chains';

  /// Path segment for the chain detail route, nested under the chains
  /// gallery.
  static const String chainDetailSegment = ':chainId';

  /// Builds the concrete path to the chains gallery.
  static String chains = '$you/$chainsSegment';

  /// Builds the concrete path to a chain's detail screen.
  static String chainDetail(String chainId) => '$chains/$chainId';

  /// Path segment for the create-quest route, nested under [quests].
  /// Declared (and registered in the router) *before* [questDetailSegment]
  /// so `/quests/new` resolves here rather than being captured as
  /// `:questId = "new"` — go_router matches sibling routes in declaration
  /// order.
  static const String questNewSegment = 'new';

  /// Path segment for the quest detail route, nested under [quests].
  static const String questDetailSegment = ':questId';

  /// Path segment for the edit-quest route, nested under the quest detail
  /// route.
  static const String questEditSegment = 'edit';

  /// Builds the concrete path to the create-quest form.
  static String questNew = '$quests/$questNewSegment';

  /// Builds the concrete path to a quest's detail screen.
  static String questDetail(String questId) => '$quests/$questId';

  /// Builds the concrete path to a quest's edit form.
  static String questEdit(String questId) =>
      '${questDetail(questId)}/$questEditSegment';
}
