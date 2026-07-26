import 'package:flutter/material.dart';

import '../../xp_ledger/presentation/xp_summary_page.dart';

/// The "You" tab is the player-profile hub per docs/architecture.md §2; its
/// first real content is the XP summary. Kept as a thin delegate so the
/// router's existing `/you` route reference never needs to change.
class YouPage extends StatelessWidget {
  const YouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const XpSummaryPage();
  }
}
