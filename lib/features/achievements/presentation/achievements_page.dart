import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import 'achievement_icon.dart';
import 'models/locked_achievement_progress.dart';
import 'models/unlocked_achievement.dart';
import 'providers/achievement_query_providers.dart';

/// Achievements gallery — reached from the You tab (see `you_page.dart`).
/// Pure read model: every number comes straight from
/// [unlockedAchievementsProvider]/[lockedAchievementsProvider], nothing is
/// computed in this widget beyond simple string formatting.
class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(unlockedAchievementsProvider);
    final lockedAsync = ref.watch(lockedAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: _buildBody(context, ref, unlockedAsync, lockedAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<UnlockedAchievement>> unlockedAsync,
    AsyncValue<List<LockedAchievementProgress>> lockedAsync,
  ) {
    if (unlockedAsync.isLoading || lockedAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (unlockedAsync.hasError) {
      return _AchievementsError(
        error: unlockedAsync.error!,
        onRetry: () => ref.invalidate(unlockedAchievementsProvider),
      );
    }
    if (lockedAsync.hasError) {
      return _AchievementsError(
        error: lockedAsync.error!,
        onRetry: () => ref.invalidate(lockedAchievementsProvider),
      );
    }

    final unlocked = unlockedAsync.value ?? const <UnlockedAchievement>[];
    final locked = lockedAsync.value ?? const <LockedAchievementProgress>[];
    final total = unlocked.length + locked.length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SummaryHeader(unlockedCount: unlocked.length, total: total),
        const SizedBox(height: AppSpacing.lg),
        Text('Unlocked', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (unlocked.isEmpty)
          const _SectionNote('None yet — complete quests to start unlocking.')
        else
          for (final entry in unlocked) ...[
            _UnlockedTile(entry: entry),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.lg),
        Text('Locked', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (locked.isEmpty)
          const _SectionNote('Every achievement is unlocked.')
        else
          for (final entry in locked) ...[
            _LockedTile(entry: entry),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.unlockedCount, required this.total});

  final int unlockedCount;
  final int total;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Unlocked', style: theme.textTheme.bodyMedium),
          Text(
            '$unlockedCount / $total',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedTile extends StatelessWidget {
  const _UnlockedTile({required this.entry});

  final UnlockedAchievement entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievement = entry.achievement;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          Icon(
            achievementIconForKey(achievement.iconKey),
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Unlocked ${_formatDate(entry.unlockedAt)}',
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
}

class _LockedTile extends StatelessWidget {
  const _LockedTile({required this.entry});

  final LockedAchievementProgress entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievement = entry.achievement;
    final hidden = achievement.hiddenUntilUnlocked;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(
            hidden
                ? Icons.help_outline
                : achievementIconForKey(achievement.iconKey),
            color: AppColors.darkTextSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hidden ? 'Hidden Achievement' : achievement.title,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  hidden
                      ? 'Keep playing to reveal this achievement.'
                      : achievement.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.progressRatio,
                    minHeight: 4,
                    backgroundColor: AppColors.darkSurfaceRaised,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.darkTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
    );
  }
}

class _AchievementsError extends StatelessWidget {
  const _AchievementsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    debugPrint('Achievements failed to load: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load your achievements.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong loading achievements. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
