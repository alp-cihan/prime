/// Route path constants — single source of truth for navigation targets.
abstract final class AppRoutes {
  static const String today = '/';
  static const String quests = '/quests';
  static const String story = '/story';
  static const String journal = '/journal';
  static const String you = '/you';
  static const String focus = '/focus';

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
