import 'package:flutter/material.dart';

import '../domain/attribute_type.dart';

/// Presentation-only icon per attribute — kept here (not in domain) for the
/// same reason as `domain_display_names.dart`, and deliberately icon-only
/// (not per-attribute color) so the app stays single-accent per the UI
/// rules; only the icon shape differentiates attributes.
IconData attributeIcon(AttributeType type) {
  switch (type) {
    case AttributeType.health:
      return Icons.favorite_outline;
    case AttributeType.strength:
      return Icons.fitness_center;
    case AttributeType.discipline:
      return Icons.self_improvement;
    case AttributeType.knowledge:
      return Icons.menu_book_outlined;
    case AttributeType.career:
      return Icons.work_outline;
    case AttributeType.finance:
      return Icons.savings_outlined;
    case AttributeType.relationships:
      return Icons.people_outline;
    case AttributeType.mindfulness:
      return Icons.spa_outlined;
  }
}
