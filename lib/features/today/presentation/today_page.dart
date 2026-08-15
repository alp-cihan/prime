import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/continue_quest_card.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/hero_mission_card.dart';
import 'widgets/player_header.dart';
import 'widgets/today_quest_list.dart';
import 'widgets/today_xp_summary.dart';

/// The Today dashboard — Prime's primary daily experience (Phase 18, "Today
/// 2.0"; docs/architecture.md §13). Visual hierarchy, top to bottom:
/// 1. Player Header — compact greeting/level/XP summary, never the
///    dominant element.
/// 2. [HeroMissionCard] — "Today's Mission," the one system-selected
///    priority quest, image-forward with an overlaid title. The screen's
///    single dominant element; everything else supports it.
/// 3. [DailyProgressCard] — "Daily momentum": completed/total + today's XP.
/// 4. [ContinueQuestCard] — a second in-progress quest worth resuming;
///    entirely absent (including its own spacing) when none qualifies.
/// 5. [TodayQuestList] — the rest of today's active quests, compact cards.
/// 6. [TodayXpSummary] — "Growth today," top 3 attributes by XP gained.
///
/// Each section owns its own provider watch and loading/error/empty state —
/// a slow or failed section never blanks the rest of the dashboard.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimePageScaffold(
      title: AppLocalizations.of(context)!.navToday,
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          PlayerHeader(),
          SizedBox(height: AppSpacing.lg),
          HeroMissionCard(),
          SizedBox(height: AppSpacing.lg),
          DailyProgressCard(),
          ContinueQuestCard(),
          SizedBox(height: AppSpacing.lg),
          TodayQuestList(),
          SizedBox(height: AppSpacing.lg),
          TodayXpSummary(),
        ],
      ),
    );
  }
}
