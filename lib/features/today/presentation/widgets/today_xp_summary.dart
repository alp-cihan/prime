import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../xp_ledger/presentation/widgets/attribute_xp_tile.dart';
import '../providers/today_dashboard_providers.dart';

/// Today dashboard "Growth today" section — the top 3 attributes with
/// non-zero XP today, sorted highest-first, reusing [AttributeXpTile]
/// (already used on the You tab's lifetime summary). The day's overall XP
/// total lives on [DailyProgressCard]'s "Daily momentum" card, not here, so
/// this section is purely about attribute-level growth. Capped at 3 per the
/// "no more than three attributes shown at once on Today" UI rule.
class TodayXpSummary extends ConsumerWidget {
  const TodayXpSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byAttributeAsync = ref.watch(todayXpByAttributeProvider);
    final theme = Theme.of(context);

    if (byAttributeAsync.isLoading) {
      return const _GrowthTodaySkeleton();
    }
    if (byAttributeAsync.hasError) {
      return _TodayXpSummaryError(
        error: byAttributeAsync.error!,
        onRetry: () => ref.invalidate(todayXpByAttributeProvider),
      );
    }

    final byAttribute = byAttributeAsync.value ?? const <AttributeType, int>{};
    final topAttributes = byAttribute.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shown = topAttributes.take(3).toList();
    final maxXp = shown.isEmpty ? 0 : shown.first.value;

    return GradientSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Growth today', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (shown.isEmpty)
            Text(
              'No XP earned today',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            )
          else
            for (final entry in shown) ...[
              AttributeXpTile(
                attribute: entry.key,
                xp: entry.value,
                progress: maxXp == 0 ? 0 : entry.value / maxXp,
              ),
              if (entry != shown.last) const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _GrowthTodaySkeleton extends StatelessWidget {
  const _GrowthTodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 96,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _TodayXpSummaryError extends StatelessWidget {
  const _TodayXpSummaryError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // See quests_page.dart's `_QuestsError` for why the raw error is never
    // rendered directly.
    debugPrint("Today's XP summary failed to load: $error");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Couldn't load today's XP.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
