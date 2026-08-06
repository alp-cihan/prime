import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../achievement_icon.dart';
import '../achievement_localization.dart';
import '../providers/achievement_evaluation_controller.dart';

/// A simple, single-achievement unlock celebration — deliberately as
/// restrained as `LevelUpDialog` (one accent-color icon, one line of text,
/// one dismiss action, no animation beyond the platform's default dialog
/// transition). Watches the controller's queue itself (rather than taking a
/// static `Achievement` parameter) so it always reflects the current front
/// of the queue even if this dialog instance is somehow rebuilt.
class AchievementUnlockDialog extends ConsumerWidget {
  const AchievementUnlockDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievement = ref.watch(
      achievementEvaluationControllerProvider.select(
        (state) =>
            state.pendingUnlocks.isEmpty ? null : state.pendingUnlocks.first,
      ),
    );
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (achievement == null) {
      // The queue was cleared from elsewhere while this dialog was still
      // open — close defensively rather than show stale/empty content (same
      // defensive pattern as LevelUpDialog).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.achievementUnlockedEyebrow,
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Icon(
              achievementIconForKey(achievement.iconKey),
              size: 48,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievementTitle(context, achievement.id),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              achievementDescription(context, achievement.id),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (achievement.rewardXp > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.rewardXpLabel(achievement.rewardXp),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.nice),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
