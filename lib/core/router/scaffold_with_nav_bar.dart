import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/providers/achievement_evaluation_controller.dart';
import '../../features/achievements/presentation/widgets/achievement_unlock_dialog.dart';
import '../../features/chains/presentation/providers/chain_evaluation_controller.dart';
import '../../features/xp_ledger/presentation/providers/level_up_controller.dart';
import '../../features/xp_ledger/presentation/widgets/level_up_dialog.dart';
import '../../l10n/app_localizations.dart';

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

    ref.listen<AchievementEvaluationState>(
      achievementEvaluationControllerProvider,
      (previous, next) {
        final hadPending = previous?.pendingUnlocks.isNotEmpty ?? false;
        final hasPending = next.pendingUnlocks.isNotEmpty;
        if (!hadPending && hasPending) {
          _showAchievementUnlockDialogs(context, ref);
        }
      },
    );

    // Chain evaluation has no dialog of its own this phase (Phase 11
    // non-goals: no completion celebration UI) — but the controller must
    // still be kept alive somewhere for its `build()` to ever run and wire
    // up its quest-completion listeners, exactly like the two providers
    // above. A bare `watch` here (this widget always rebuilds when the
    // shell exists) is the simplest way to do that without inventing a
    // dialog just to justify the read.
    ref.watch(chainEvaluationControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l10n.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l10n.navQuests,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories),
            label: l10n.navStory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_outlined),
            selectedIcon: const Icon(Icons.book),
            label: l10n.navJournal,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navYou,
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

  /// Shows one dialog per queued unlock, sequentially — a batch of several
  /// simultaneous unlocks (Phase 10: "one quest completion may unlock
  /// multiple achievements safely") is never collapsed into a single dialog,
  /// each gets shown once and acknowledged before the next appears.
  Future<void> _showAchievementUnlockDialogs(
    BuildContext context,
    WidgetRef ref,
  ) async {
    while (ref
        .read(achievementEvaluationControllerProvider)
        .pendingUnlocks
        .isNotEmpty) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const AchievementUnlockDialog(),
      );
      if (!context.mounted) return;
      ref
          .read(achievementEvaluationControllerProvider.notifier)
          .acknowledgeFirst();
    }
  }
}
