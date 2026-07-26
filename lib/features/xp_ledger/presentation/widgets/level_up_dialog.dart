import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../providers/level_up_controller.dart';

/// docs/architecture.md §14 — the level-up celebration overlay. Watches
/// [levelUpControllerProvider] itself (rather than taking a static
/// [LevelUpEvent] parameter) so that if the pending event is widened by a
/// second crossing while this dialog is already on screen (see
/// `LevelUpController`'s merge behavior), it always reflects the latest
/// numbers instead of the stale ones it was first built with.
///
/// Deliberately restrained per the closing checklist in §22: a single
/// accent-color numeral, no particle/confetti animation, one dismiss action.
class LevelUpDialog extends ConsumerWidget {
  const LevelUpDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(
      levelUpControllerProvider.select((state) => state.pendingEvent),
    );
    final theme = Theme.of(context);

    if (event == null) {
      // The pending event was cleared from elsewhere while this dialog was
      // still open (e.g. a programmatic acknowledge) — close defensively
      // rather than show stale/empty content.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    final isMultiLevelJump = event.newLevel - event.previousLevel > 1;

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
              'LEVEL UP',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${event.newLevel}',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 56,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isMultiLevelJump
                  ? 'Level ${event.previousLevel} → Level ${event.newLevel}'
                  : 'You reached a new level',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
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
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
