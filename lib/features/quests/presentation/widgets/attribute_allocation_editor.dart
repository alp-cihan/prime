import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../l10n/app_localizations.dart';

/// One editable attribute-weight row. Owns the [TextEditingController] for
/// its weight field so [AttributeAllocationEditor] stays presentational
/// (no internal state) while the parent [QuestForm] still keeps a single
/// controller per row across rebuilds. Callers must call [dispose] when a
/// row is discarded.
class AttributeAllocationRow {
  AttributeAllocationRow({required this.type, int initialWeight = 0})
    : weightController = TextEditingController(text: initialWeight.toString());

  AttributeType type;
  final TextEditingController weightController;

  void dispose() => weightController.dispose();
}

/// Editor for a [Quest.attributeXpWeights]-shaped allocation: one row per
/// attribute in play, each an [AttributeType] dropdown plus an integer
/// weight field. Does not invent a new allocation system — this is exactly
/// the existing weighted-map domain shape, just made editable.
///
/// Pure presentational: [rows] and their controllers are owned by the
/// caller; this widget only renders them and reports intent via callbacks.
/// Duplicate [AttributeType]s across rows are prevented by disabling
/// already-used types in every other row's dropdown, rather than merging —
/// simplest deterministic behavior for this MVP.
class AttributeAllocationEditor extends StatelessWidget {
  const AttributeAllocationEditor({
    super.key,
    required this.rows,
    required this.onAttributeChanged,
    required this.onWeightChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final List<AttributeAllocationRow> rows;
  final void Function(int index, AttributeType type) onAttributeChanged;
  final void Function(int index, String rawValue) onWeightChanged;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final usedTypes = rows.map((r) => r.type).toSet();
    final total = rows.fold<int>(
      0,
      (sum, row) => sum + (int.tryParse(row.weightController.text) ?? 0),
    );
    final canAddMore = rows.length < AttributeType.values.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.attributeAllocationLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < rows.length; i++) ...[
          _AttributeRowEditor(
            row: rows[i],
            usedByOtherRows: usedTypes.difference({rows[i].type}),
            onAttributeChanged: (type) => onAttributeChanged(i, type),
            onWeightChanged: (value) => onWeightChanged(i, value),
            onRemove: rows.length > 1 ? () => onRemove(i) : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: TextButton.icon(
                onPressed: canAddMore ? onAdd : null,
                icon: const Icon(Icons.add),
                label: Text(
                  l10n.addAttributeButton,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                l10n.totalXpLabel(total),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AttributeRowEditor extends StatelessWidget {
  const _AttributeRowEditor({
    required this.row,
    required this.usedByOtherRows,
    required this.onAttributeChanged,
    required this.onWeightChanged,
    required this.onRemove,
  });

  final AttributeAllocationRow row;
  final Set<AttributeType> usedByOtherRows;
  final ValueChanged<AttributeType> onAttributeChanged;
  final ValueChanged<String> onWeightChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<AttributeType>(
            initialValue: row.type,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.attributeLabel),
            items: [
              for (final type in AttributeType.values)
                DropdownMenuItem(
                  value: type,
                  enabled: !usedByOtherRows.contains(type),
                  child: Text(
                    attributeDisplayName(context, type),
                    overflow: TextOverflow.ellipsis,
                    style: usedByOtherRows.contains(type)
                        ? TextStyle(color: AppColors.darkTextSecondary)
                        : null,
                  ),
                ),
            ],
            onChanged: (next) {
              if (next != null) onAttributeChanged(next);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: row.weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.xpWeightLabel),
            onChanged: onWeightChanged,
            validator: (value) {
              final parsed = int.tryParse(value?.trim() ?? '');
              if (parsed == null) return l10n.enterWholeNumberError;
              if (parsed < 0) return l10n.mustNotBeNegativeError;
              return null;
            },
          ),
        ),
        if (onRemove != null)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: l10n.removeAttributeTooltip,
          ),
      ],
    );
  }
}
