import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../achievements/presentation/achievement_icon.dart';
import '../../../chains/presentation/chain_icon.dart';
import '../../domain/entities/identity_milestone.dart';

/// Recent-milestones timeline — newest first, one row per
/// [IdentityMilestone]. Reuses the achievements/chains features' own icon
/// mappings (Phase 12: "Use existing icon system where possible") rather
/// than inventing a third one.
class IdentityTimeline extends StatelessWidget {
  const IdentityTimeline({super.key, required this.milestones});

  final List<IdentityMilestone> milestones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Milestones', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (milestones.isEmpty)
          Text(
            'No milestones yet — complete quests to start building your story.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          )
        else
          for (final milestone in milestones) ...[
            _MilestoneTile(milestone: milestone),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final IdentityMilestone milestone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_iconFor(milestone), color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title, style: theme.textTheme.titleSmall),
                Text(
                  _formatDate(milestone.occurredAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(IdentityMilestone milestone) {
    switch (milestone.type) {
      case IdentityMilestoneType.levelReached:
        return Icons.star_outline;
      case IdentityMilestoneType.achievementUnlocked:
        return achievementIconForKey(milestone.iconKey);
      case IdentityMilestoneType.chainCompleted:
        return chainIconForKey(milestone.iconKey);
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
