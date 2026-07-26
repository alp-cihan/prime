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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            attributeDisplayName(attribute),
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            '$xp XP',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
