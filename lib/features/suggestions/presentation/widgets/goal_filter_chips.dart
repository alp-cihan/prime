import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/recommendation_profile.dart';

/// Horizontally scrollable goal-area filter row for the Suggestions page.
/// Purely controlled — holds no state of its own, so it stays a dumb widget
/// the same way `QuestCard` does.
class GoalFilterChips extends StatelessWidget {
  const GoalFilterChips({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<GoalArea> selected;
  final ValueChanged<GoalArea> onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GoalArea.values.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          final goal = GoalArea.values[index];
          final isSelected = selected.contains(goal);
          return ChoiceChip(
            label: Text(goalAreaDisplayName(context, goal)),
            avatar: Icon(goalAreaIcon(goal), size: 16),
            selected: isSelected,
            onSelected: (_) => onToggle(goal),
            selectedColor: AppColors.accent,
            backgroundColor: AppColors.darkSurface,
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isSelected ? Colors.white : AppColors.darkTextPrimary,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.accent : AppColors.darkBorder,
            ),
          );
        },
      ),
    );
  }
}
