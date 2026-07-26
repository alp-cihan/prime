import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../xp_ledger/presentation/widgets/attribute_xp_tile.dart';
import '../providers/today_dashboard_providers.dart';

/// Today dashboard §13 Activity/XP Summary — today's total XP plus a
/// per-attribute breakdown, reusing [AttributeXpTile] (already used on the
/// You tab's lifetime summary). Only attributes with non-zero XP today are
/// rendered — [todayXpByAttributeProvider] never includes zero entries.
class TodayXpSummary extends ConsumerWidget {
  const TodayXpSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAsync = ref.watch(todayXpTotalProvider);
    final byAttributeAsync = ref.watch(todayXpByAttributeProvider);
    final theme = Theme.of(context);

    if (totalAsync.isLoading || byAttributeAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (totalAsync.hasError) {
      return _TodayXpSummaryError(
        error: totalAsync.error!,
        onRetry: () => ref.invalidate(todayXpTotalProvider),
      );
    }
    if (byAttributeAsync.hasError) {
      return _TodayXpSummaryError(
        error: byAttributeAsync.error!,
        onRetry: () => ref.invalidate(todayXpByAttributeProvider),
      );
    }

    final total = totalAsync.value ?? 0;
    final byAttribute = byAttributeAsync.value ?? const <AttributeType, int>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XP earned today', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (total == 0)
          Text(
            'No XP earned today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          )
        else ...[
          Text(
            '$total XP',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final entry in byAttribute.entries) ...[
            AttributeXpTile(attribute: entry.key, xp: entry.value),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
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

    return Row(
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
    );
  }
}
