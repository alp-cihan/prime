import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/quest.dart';

/// Pure presentational [QuestDifficulty] picker — no provider reads, no
/// internal state; the caller owns the current value.
class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final QuestDifficulty value;
  final ValueChanged<QuestDifficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<QuestDifficulty>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Difficulty'),
      items: [
        for (final difficulty in QuestDifficulty.values)
          DropdownMenuItem(
            value: difficulty,
            child: Text(questDifficultyDisplayName(difficulty)),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
