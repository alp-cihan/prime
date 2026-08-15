import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/lifetime_statistics.dart';

/// "Your Journey" — Identity 2.0's replacement for the old "Lifetime"
/// stat-table section. Same underlying [LifetimeStatistics] projection,
/// presented as a small row of visually distinct stat cards (icon + number
/// + label) instead of a dense grid, so it reads as a journey summary
/// rather than an accounting table.
class IdentityJourneySection extends StatelessWidget {
  const IdentityJourneySection({super.key, required this.statistics});

  final LifetimeStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final cards = [
      _JourneyStat(
        icon: Icons.local_fire_department_outlined,
        value: '${statistics.currentStreakDays}',
        label: l10n.streakDaysLabel,
      ),
      _JourneyStat(
        icon: Icons.check_circle_outline,
        value: '${statistics.completedQuests}',
        label: l10n.questsCompletedLabel,
      ),
      _JourneyStat(
        icon: Icons.bolt_outlined,
        value: formatXp(statistics.totalXpEarned),
        label: l10n.totalXpEarnedLabel,
      ),
      _JourneyStat(
        icon: Icons.emoji_events_outlined,
        value: '${statistics.unlockedAchievements}',
        label: l10n.achievementsUnlockedLabel,
      ),
      _JourneyStat(
        icon: Icons.link,
        value: '${statistics.completedChains}',
        label: l10n.chainsCompletedLabel,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.journeyHeader, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final card in cards) ...[
                card,
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _JourneyStat extends StatelessWidget {
  const _JourneyStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 116,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
