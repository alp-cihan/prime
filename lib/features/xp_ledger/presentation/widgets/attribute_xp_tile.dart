import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';

/// Pure presentational row showing one attribute's lifetime XP. No provider
/// reads — the caller passes the already-derived total in.
class AttributeXpTile extends StatelessWidget {
  const AttributeXpTile({super.key, required this.attribute, required this.xp});

  final AttributeType attribute;
  final int xp;

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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            attributeDisplayName(attribute),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          // An attribute's lifetime XP has no upper bound — this side must
          // be allowed to shrink/truncate rather than overflow a narrow
          // screen.
          Expanded(
            child: Text(
              '$xp XP',
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
