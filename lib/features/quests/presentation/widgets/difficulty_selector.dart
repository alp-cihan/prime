import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<QuestDifficulty>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.difficultyLabel),
      items: [
        for (final difficulty in QuestDifficulty.values)
          DropdownMenuItem(
            value: difficulty,
            child: Text(
              questDifficultyDisplayName(context, difficulty),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }
}
