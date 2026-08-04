import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/featured_quest_card.dart';
import 'widgets/player_header.dart';
import 'widgets/today_quest_list.dart';
import 'widgets/today_xp_summary.dart';

/// The Today dashboard (docs/architecture.md §13, Phase 6 MVP subset):
/// Hero Player Header, Featured (Main) Quest, Daily Momentum, Daily Quest
/// List, and Growth Today (Activity/XP Summary). Boss/Story card and
/// Identity Evidence are later phases, deliberately not included here.
///
/// Each section owns its own provider watch and loading/error/empty state —
/// a slow or failed section never blanks the rest of the dashboard.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimePageScaffold(
      title: 'Today',
      body: ListView(
        padding: EdgeInsets.zero,
        children: const [
          PlayerHeader(),
          SizedBox(height: AppSpacing.lg),
          FeaturedQuestCard(),
          SizedBox(height: AppSpacing.lg),
          DailyProgressCard(),
          SizedBox(height: AppSpacing.lg),
          TodayQuestList(),
          SizedBox(height: AppSpacing.lg),
          TodayXpSummary(),
        ],
      ),
    );
  }
}
