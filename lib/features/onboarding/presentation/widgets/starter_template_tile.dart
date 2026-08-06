import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/catalog/starter_quest_template.dart';
import '../starter_template_localization.dart';

/// A single selectable starter-quest suggestion — tapping toggles selection;
/// nothing is created until the onboarding page's own "Get Started" action
/// (Phase 14: "do not silently insert quests without consent").
class StarterTemplateTile extends StatelessWidget {
  const StarterTemplateTile({
    super.key,
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final StarterQuestTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryAttribute = template.attributeXpWeights.keys.first;

    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.darkBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected
                    ? AppColors.accent
                    : AppColors.darkTextSecondary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      starterTemplateTitle(context, template.id),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${attributeDisplayName(context, primaryAttribute)} · '
                      '${questDifficultyDisplayName(context, template.difficulty)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
