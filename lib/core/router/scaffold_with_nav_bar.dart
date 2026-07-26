import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/xp_ledger/presentation/providers/level_up_controller.dart';
import '../../features/xp_ledger/presentation/widgets/level_up_dialog.dart';

/// Bottom navigation chrome for the 5-tab shell. Each branch keeps its own
/// navigation stack via [StatefulShellRoute.indexedStack] — switching tabs
/// never resets the stack of the tab being left.
///
/// Also owns the single level-up overlay boundary (docs/architecture.md
/// §14): this widget sits above every tab's `Navigator` and survives tab
/// switches (it is the `StatefulShellRoute`'s own shell widget, not
/// per-branch content), so one listener here reliably catches a level-up
/// regardless of which tab triggered it — no per-tab duplicate listeners.
class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LevelUpControllerState>(levelUpControllerProvider, (
      previous,
      next,
    ) {
      final hadPending = previous?.pendingEvent != null;
      final hasPending = next.pendingEvent != null;
      if (!hadPending && hasPending) {
        _showLevelUpDialog(context, ref);
      }
    });

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Quests',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Story',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'You',
          ),
        ],
      ),
    );
  }

  /// Shown from [ref.listen]'s callback (a side-effect boundary, not
  /// `build`) — the only way a dialog can be triggered here without racing
  /// this widget's own rebuilds. Acknowledges exactly once, after the
  /// dialog closes by whatever means (Continue button or barrier tap), and
  /// only if this element is still mounted post-await.
  Future<void> _showLevelUpDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LevelUpDialog(),
    );
    if (!context.mounted) return;
    ref.read(levelUpControllerProvider.notifier).acknowledge();
  }
}
