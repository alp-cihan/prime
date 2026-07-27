import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// Not implemented yet. Shown as an intentional, restrained placeholder
/// rather than a bare title so the tab never reads as broken (Phase 13:
/// "no dead-end screens").
class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrimePageScaffold(
      title: 'Journal',
      body: ComingSoonView(
        icon: Icons.book_outlined,
        message: 'Journaling is coming soon.',
      ),
    );
  }
}
