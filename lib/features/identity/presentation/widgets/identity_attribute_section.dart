import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/attribute_distribution.dart';

/// Attribute breakdown section — one card per attribute with its share of
/// lifetime XP, and the strongest/weakest called out. [distribution]
/// already carries the computed strongest/weakest through from
/// `IdentitySnapshot`; this widget never recomputes them.
class IdentityAttributeSection extends StatelessWidget {
  const IdentityAttributeSection({super.key, required this.distribution});

  final AttributeDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.attributesHeader,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final type in AttributeType.values) ...[
          _AttributeCard(
            type: type,
            xp: distribution.xpByAttribute[type] ?? 0,
            percent: distribution.percentOf(type),
            isStrongest: distribution.strongest == type,
            isWeakest: distribution.weakest == type,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _AttributeCard extends StatelessWidget {
  const _AttributeCard({
    required this.type,
    required this.xp,
    required this.percent,
    required this.isStrongest,
    required this.isWeakest,
  });

  final AttributeType type;
  final int xp;
  final double percent;
  final bool isStrongest;
  final bool isWeakest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final badge = isStrongest
        ? l10n.strongestBadge
        : (isWeakest ? l10n.weakestBadge : null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStrongest ? AppColors.accent : AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    attributeDisplayName(context, type),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isStrongest
                              ? AppColors.accent
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                l10n.percentValue((percent * 100).round()),
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 4,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$xp XP',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
