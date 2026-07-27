import 'package:flutter/widgets.dart';

/// Wraps the app's [ProviderScope] and lets any descendant force a full,
/// cold rebuild of everything beneath it — every provider, every `keepAlive`
/// controller, disposed and recreated from scratch.
///
/// This is the mechanism "clear all local data" (Settings) uses to reset the
/// app to first-run state: after the Hive boxes are deleted and reopened
/// empty, dozens of `keepAlive` providers/controllers across every feature
/// still hold state derived from the *old* boxes (cached repository
/// instances, `LevelUpController`'s XP baseline, etc.). Rather than trying to
/// enumerate and invalidate each one individually — fragile, and only as
/// correct as the last person to remember to update the list — changing this
/// widget's key throws the entire subtree away and rebuilds it fresh, which
/// is the only way to *guarantee* "never leave providers/controllers in a
/// corrupted state".
class AppRestartScope extends StatefulWidget {
  const AppRestartScope({super.key, required this.child});

  final Widget child;

  /// Call from anywhere beneath an [AppRestartScope] to trigger the reset.
  static void restart(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartScopeState>()!.restart();
  }

  @override
  State<AppRestartScope> createState() => _AppRestartScopeState();
}

class _AppRestartScopeState extends State<AppRestartScope> {
  Key _subtreeKey = UniqueKey();

  void restart() => setState(() => _subtreeKey = UniqueKey());

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _subtreeKey, child: widget.child);
  }
}
