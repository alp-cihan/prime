import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../domain/entities/quest_progress.dart';

/// Pure presentational "today" summary for a quest — every number it shows
/// is passed in already computed from domain data; it performs no XP
/// calculation of its own, only display aggregation over already-final
/// [XpTransaction] rows (counting rows / summing `finalXp`).
class QuestProgressSummary extends StatelessWidget {
  const QuestProgressSummary({
    super.key,
    required this.progress,
    required this.transactions,
    required this.isLoading,
  });

  final QuestProgress? progress;
  final List<XpTransaction> transactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          Text(l10n.todayLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildContent(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    final completionsToday = transactions.map((t) => t.sourceId).toSet().length;
    final xpToday = transactions.fold<int>(0, (sum, t) => sum + t.finalXp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow(
          label: l10n.completedTodayLabel,
          value: completionsToday == 0
              ? l10n.notYetLabel
              : l10n.completionsCount(completionsToday),
        ),
        const SizedBox(height: AppSpacing.xs),
        _StatRow(
          label: l10n.xpEarnedTodayLabel,
          value: l10n.xpAmount(xpToday.toString()),
        ),
        if (progress?.notes != null && progress!.notes!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            progress!.notes!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
