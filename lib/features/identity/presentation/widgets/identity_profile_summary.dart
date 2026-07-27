import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/identity_snapshot.dart';

/// Profile summary section — current level, lifetime XP, and progress
/// toward the next level. Every number comes straight off [snapshot];
/// nothing is recomputed here.
class IdentityProfileSummary extends StatelessWidget {
  const IdentityProfileSummary({super.key, required this.snapshot});

  final IdentitySnapshot snapshot;

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
          Row(
            children: [
              Text(
                'Level ${snapshot.currentLevel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              // A long-time player's lifetime XP has no upper bound, so this
              // is the one side of the row that must be allowed to shrink
              // (and, in the extreme, truncate) rather than push the row
              // past a narrow screen's width.
              Expanded(
                child: Text(
                  '${snapshot.lifetimeXp} XP',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: snapshot.progressRatio,
              minHeight: 6,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${snapshot.xpIntoCurrentLevel} / ${snapshot.xpNeededForNextLevel} XP to next level',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
