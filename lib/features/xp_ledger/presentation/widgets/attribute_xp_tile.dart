import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';

/// Pure presentational row showing one attribute's XP. No provider reads —
/// the caller passes the already-derived total in. [progress] is an
/// optional, already-computed 0..1 relative visual weight (e.g. this
/// attribute's XP against the largest shown); when omitted, no bar is
/// rendered — the You tab's lifetime summary uses the tile this way.
class AttributeXpTile extends StatelessWidget {
  const AttributeXpTile({
    super.key,
    required this.attribute,
    required this.xp,
    this.progress,
  });

  final AttributeType attribute;
  final int xp;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceRaised,
              shape: BoxShape.circle,
            ),
            child: Icon(
              attributeIcon(attribute),
              size: 18,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attributeDisplayName(attribute),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress!.clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: AppColors.darkSurfaceRaised,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // An attribute's XP has no upper bound — this side must be
          // allowed to shrink/truncate rather than overflow a narrow
          // screen.
          Flexible(
            child: Text(
              '${formatXp(xp)} XP',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
