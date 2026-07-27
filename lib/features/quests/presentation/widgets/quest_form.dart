import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../core/domain/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../application/models/create_quest_command.dart';
import '../../application/models/update_quest_command.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/repeatability.dart';
import '../providers/quest_form_controller.dart';
import 'attribute_allocation_editor.dart';
import 'difficulty_selector.dart';

/// The user-facing quest types this Phase 7 form exposes. `epic`/`mainStory`
/// belong to Quest Chains (not implemented), `repeatable` is an internal-only
/// representation (docs/architecture.md §5.1), and `recovery` is
/// system-generated — none of those are user-creatable here.
const _selectableQuestTypes = [
  QuestType.daily,
  QuestType.weekly,
  QuestType.monthly,
  QuestType.side,
];

/// The user-facing repeatability options this form exposes — every
/// [Repeatability] value is selectable (the enum has no internal-only
/// members, unlike [QuestType]).
const _repeatabilityOptions = Repeatability.values;

/// Create/edit quest form. In create mode ([questId] is null) it starts from
/// defaults; in edit mode it is only ever constructed once
/// [QuestFormPage] has already loaded [initialQuest] — so this widget never
/// has to represent "still loading" itself.
///
/// Owns local field state and its own [Form] validation for immediate
/// feedback, but domain validation (`QuestInputValidator`, via the use
/// cases) remains the final authority — see `_submit`.
class QuestForm extends ConsumerStatefulWidget {
  const QuestForm({super.key, this.questId, this.initialQuest})
    : assert(
        (questId == null) == (initialQuest == null),
        'questId and initialQuest must both be null (create) or both set (edit)',
      );

  /// Null in create mode; the quest being edited's id in edit mode.
  final String? questId;

  /// Null in create mode; the already-loaded quest in edit mode.
  final Quest? initialQuest;

  @override
  ConsumerState<QuestForm> createState() => _QuestFormState();
}

class _QuestFormState extends ConsumerState<QuestForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetProgressController;
  late QuestType _type;
  late QuestDifficulty _difficulty;
  late ProgressType _progressType;
  late Repeatability _repeatability;
  late List<AttributeAllocationRow> _attributeRows;

  bool get _isEditMode => widget.questId != null;

  @override
  void initState() {
    super.initState();
    final quest = widget.initialQuest;

    _titleController = TextEditingController(text: quest?.title ?? '');
    _descriptionController = TextEditingController(
      text: quest?.description ?? '',
    );
    _type = quest?.type ?? QuestType.daily;
    _difficulty = quest?.difficulty ?? QuestDifficulty.normal;
    _progressType = quest?.progressType ?? ProgressType.binary;
    _targetProgressController = TextEditingController(
      text: (quest?.targetProgress ?? 1).toString(),
    );
    _repeatability = quest?.repeatability ?? Repeatability.none;
    _attributeRows = quest == null || quest.attributeXpWeights.isEmpty
        ? [AttributeAllocationRow(type: AttributeType.health)]
        : [
            for (final entry in quest.attributeXpWeights.entries)
              AttributeAllocationRow(
                type: entry.key,
                initialWeight: entry.value,
              ),
          ];

    // A shared, keepAlive controller can be carrying a stale success/error
    // from a previous, unrelated form session — clear it so a freshly
    // opened form never shows another quest's leftover state.
    Future.microtask(
      () => ref.read(questFormControllerProvider.notifier).reset(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetProgressController.dispose();
    for (final row in _attributeRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Quest?>>(questFormControllerProvider, (
      previous,
      next,
    ) {
      final quest = next.value;
      if (next.hasValue && quest != null) {
        if (!context.mounted) return;
        if (_isEditMode) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.questDetail(quest.id));
          }
        } else {
          context.go(AppRoutes.questDetail(quest.id));
        }
        // Idle again immediately so this success can't linger into a later
        // form session.
        ref.read(questFormControllerProvider.notifier).reset();
      } else if (next.hasError) {
        debugPrint('Quest form submission failed: ${next.error}');
      }
    });

    final controllerState = ref.watch(questFormControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length > 100) {
                  return 'Title must be 100 characters or fewer';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLength: 500,
              maxLines: 3,
              validator: (value) {
                if ((value ?? '').trim().length > 500) {
                  return 'Description must be 500 characters or fewer';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<QuestType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Quest type'),
              items: [
                for (final type in _selectableQuestTypes)
                  DropdownMenuItem(
                    value: type,
                    child: Text(questTypeDisplayName(type)),
                  ),
              ],
              onChanged: (next) {
                if (next != null) setState(() => _type = next);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            DifficultySelector(
              value: _difficulty,
              onChanged: (next) => setState(() => _difficulty = next),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<ProgressType>(
              initialValue: _progressType,
              decoration: const InputDecoration(labelText: 'Progress type'),
              items: [
                for (final type in ProgressType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(progressTypeDisplayName(type)),
                  ),
              ],
              onChanged: (next) {
                if (next == null) return;
                setState(() {
                  _progressType = next;
                  if (next == ProgressType.binary) {
                    _targetProgressController.text = '1';
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _targetProgressController,
              enabled: _progressType != ProgressType.binary,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Target progress'),
              validator: (value) {
                if (_progressType == ProgressType.binary) return null;
                final parsed = double.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AttributeAllocationEditor(
              rows: _attributeRows,
              onAttributeChanged: (index, type) =>
                  setState(() => _attributeRows[index].type = type),
              onWeightChanged: (index, rawValue) => setState(() {}),
              onAdd: () => setState(() {
                final unused = AttributeType.values.firstWhere(
                  (type) => !_attributeRows.any((row) => row.type == type),
                );
                _attributeRows.add(AttributeAllocationRow(type: unused));
              }),
              onRemove: (index) => setState(() {
                _attributeRows.removeAt(index).dispose();
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<Repeatability>(
              initialValue: _repeatability,
              decoration: const InputDecoration(labelText: 'Repeats'),
              items: [
                for (final option in _repeatabilityOptions)
                  DropdownMenuItem(
                    value: option,
                    child: Text(repeatabilityDisplayName(option)),
                  ),
              ],
              onChanged: (next) {
                if (next != null) setState(() => _repeatability = next);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (controllerState.hasError) ...[
              _FormError(failure: controllerState.error),
              const SizedBox(height: AppSpacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controllerState.isLoading ? null : _submit,
                child: controllerState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditMode ? 'Save Changes' : 'Create Quest'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final weights = <AttributeType, int>{
      for (final row in _attributeRows)
        row.type: int.tryParse(row.weightController.text.trim()) ?? 0,
    };
    final targetProgress = _progressType == ProgressType.binary
        ? 1.0
        : double.tryParse(_targetProgressController.text.trim()) ?? 0.0;

    final notifier = ref.read(questFormControllerProvider.notifier);
    if (_isEditMode) {
      notifier.updateQuest(
        UpdateQuestCommand(
          questId: widget.questId!,
          title: _titleController.text,
          description: _descriptionController.text,
          type: _type,
          difficulty: _difficulty,
          attributeXpWeights: weights,
          progressType: _progressType,
          targetProgress: targetProgress,
          repeatability: _repeatability,
        ),
      );
    } else {
      notifier.create(
        CreateQuestCommand(
          title: _titleController.text,
          description: _descriptionController.text,
          type: _type,
          difficulty: _difficulty,
          attributeXpWeights: weights,
          progressType: _progressType,
          targetProgress: targetProgress,
          repeatability: _repeatability,
        ),
      );
    }
  }
}

class _FormError extends StatelessWidget {
  const _FormError({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final message = failure is Failure
        ? (failure as Failure).message
        : 'Something went wrong. Please try again.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
      ),
    );
  }
}
