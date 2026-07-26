import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/focus/presentation/focus_page.dart';
import '../../features/journal/presentation/journal_page.dart';
import '../../features/quests/presentation/pages/quest_form_page.dart';
import '../../features/quests/presentation/quest_detail_page.dart';
import '../../features/quests/presentation/quests_page.dart';
import '../../features/story/presentation/story_page.dart';
import '../../features/today/presentation/today_page.dart';
import '../../features/you/presentation/you_page.dart';
import 'app_routes.dart';
import 'scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

/// The app's single [GoRouter] instance. Generated as a Riverpod provider
/// (rather than a bare top-level constant) so later phases can inject
/// auth/onboarding redirects without changing how the router is consumed.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.quests,
                builder: (context, state) => const QuestsPage(),
                routes: [
                  // Nested under the quests branch (not a separate shell
                  // destination) so detail/form screens keep the bottom nav
                  // visible and share this branch's own navigation stack —
                  // per docs/architecture.md §19 and the
                  // StatefulShellRoute.indexedStack pattern already in use.
                  //
                  // `new` is declared *before* `:questId` — go_router tries
                  // sibling routes in declaration order, so `/quests/new`
                  // resolves to this literal route rather than being
                  // captured as `:questId = "new"`.
                  GoRoute(
                    path: AppRoutes.questNewSegment,
                    builder: (context, state) => const QuestFormPage(),
                  ),
                  GoRoute(
                    path: AppRoutes.questDetailSegment,
                    builder: (context, state) {
                      final questId = state.pathParameters['questId']!;
                      return QuestDetailPage(questId: questId);
                    },
                    routes: [
                      GoRoute(
                        path: AppRoutes.questEditSegment,
                        builder: (context, state) {
                          final questId = state.pathParameters['questId']!;
                          return QuestFormPage(questId: questId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.story,
                builder: (context, state) => const StoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const JournalPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.you,
                builder: (context, state) => const YouPage(),
              ),
            ],
          ),
        ],
      ),
      // Outside the shell — Focus Mode must never live in the tab chrome.
      GoRoute(
        path: AppRoutes.focus,
        builder: (context, state) => const FocusPage(),
      ),
    ],
  );
}
