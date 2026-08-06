import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/lifetime_statistics.dart';

/// Lifetime statistics section — quests completed, chains completed,
/// achievements unlocked, total XP earned. A simple 2x2 grid of stat
/// tiles, consistent with the rest of the app's restrained, numbers-first
/// visual language.
class IdentityLifetimeSection extends StatelessWidget {
  const IdentityLifetimeSection({super.key, required this.statistics});

  final LifetimeStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lifetimeHeader, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.questsCompletedLabel,
                value: '${statistics.completedQuests}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: l10n.chainsCompletedLabel,
                value: '${statistics.completedChains}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.achievementsUnlockedLabel,
                value: '${statistics.unlockedAchievements}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: l10n.totalXpEarnedLabel,
                value: '${statistics.totalXpEarned}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
