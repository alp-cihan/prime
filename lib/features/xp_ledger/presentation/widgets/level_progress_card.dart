import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/services/level_curve.dart';

/// Pure presentational level card. [levelProgress] is expected to already be
/// derived via the domain's [LevelCurve] — this widget performs no XP math
/// of its own, only a divide for the progress-bar fraction.
class LevelProgressCard extends StatelessWidget {
  const LevelProgressCard({
    super.key,
    required this.levelProgress,
    required this.totalXp,
  });

  final LevelProgress levelProgress;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progressFraction = levelProgress.xpRequiredForNextLevel == 0
        ? 0.0
        : (levelProgress.currentXpIntoLevel /
                  levelProgress.xpRequiredForNextLevel)
              .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.playerLevelLabel(levelProgress.level),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(width: AppSpacing.sm),
              // Lifetime XP has no upper bound — this side must be allowed
              // to shrink/truncate rather than overflow a narrow screen.
              Expanded(
                child: Text(
                  l10n.playerXpTotal(totalXp.toString()),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 8,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.playerXpToNextLevel(
              levelProgress.currentXpIntoLevel,
              levelProgress.xpRequiredForNextLevel,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
