import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// Main Story Quests / Quest Chains land here per docs/architecture.md §2,
/// but Quest Chains shipped in Phase 11 under the You tab instead (alongside
/// Achievements/Identity) — no chain content lives here yet. Shown as an
/// intentional, restrained placeholder rather than a bare title so the tab
/// never reads as broken (Phase 13: "no dead-end screens").
class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrimePageScaffold(
      title: 'Story',
      body: ComingSoonView(
        icon: Icons.auto_stories_outlined,
        message: 'Your story is still being written.\nCheck back soon.',
      ),
    );
  }
}
