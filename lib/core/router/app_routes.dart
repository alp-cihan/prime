/// Route path constants — single source of truth for navigation targets.
abstract final class AppRoutes {
  static const String today = '/';
  static const String quests = '/quests';
  static const String story = '/story';
  static const String journal = '/journal';
  static const String you = '/you';
  static const String focus = '/focus';

  /// Path segment for the quest detail route, nested under [quests].
  static const String questDetailSegment = ':questId';

  /// Builds the concrete path to a quest's detail screen.
  static String questDetail(String questId) => '$quests/$questId';
}
