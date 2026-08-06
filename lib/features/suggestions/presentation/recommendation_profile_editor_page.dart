import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/entities/recommendation_profile.dart';
import 'providers/recommendation_profile_controller.dart';

/// Concise, one-screen preferences editor (Phase 16: "no long
/// questionnaire") — reachable from the Suggestions page's toolbar and from
/// Settings, so it can be revisited any time, not just during onboarding.
class RecommendationProfileEditorPage extends ConsumerStatefulWidget {
  const RecommendationProfileEditorPage({super.key});

  @override
  ConsumerState<RecommendationProfileEditorPage> createState() =>
      _RecommendationProfileEditorPageState();
}

class _RecommendationProfileEditorPageState
    extends ConsumerState<RecommendationProfileEditorPage> {
  LifeStage? _lifeStage;
  Set<GoalArea>? _goals;
  AvailableTime? _availableTime;
  PreferredIntensity? _intensity;
  bool _initialized = false;

  void _initializeFrom(RecommendationProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _lifeStage = profile.lifeStage;
    _goals = {...profile.goals};
    _availableTime = profile.availableTime;
    _intensity = profile.intensity;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(recommendationProfileControllerProvider);

    ref.listen<AsyncValue<RecommendationProfile>>(
      recommendationProfileControllerProvider,
      (previous, next) {
        if (previous?.isLoading == true && next.hasValue && _initialized) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.preferencesSaved),
            ),
          );
          context.pop();
        } else if (next.hasError) {
          debugPrint('Save recommendation profile failed: ${next.error}');
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.suggestionPreferencesTitle),
      ),
      body: profileAsync.when(
        data: (profile) {
          _initializeFrom(profile);
          return _EditorBody(
            lifeStage: _lifeStage!,
            goals: _goals!,
            availableTime: _availableTime!,
            intensity: _intensity!,
            isSaving: profileAsync.isLoading,
            onLifeStageChanged: (value) => setState(() => _lifeStage = value),
            onGoalToggled: (goal) => setState(() {
              final goals = _goals!;
              _goals = goals.contains(goal)
                  ? ({...goals}..remove(goal))
                  : {...goals, goal};
            }),
            onAvailableTimeChanged: (value) =>
                setState(() => _availableTime = value),
            onIntensityChanged: (value) => setState(() => _intensity = value),
            onSave: () => ref
                .read(recommendationProfileControllerProvider.notifier)
                .save(
                  profile.copyWith(
                    lifeStage: _lifeStage,
                    goals: _goals,
                    availableTime: _availableTime,
                    intensity: _intensity,
                  ),
                ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              AppLocalizations.of(context)!.couldntLoadPreferences,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.lifeStage,
    required this.goals,
    required this.availableTime,
    required this.intensity,
    required this.isSaving,
    required this.onLifeStageChanged,
    required this.onGoalToggled,
    required this.onAvailableTimeChanged,
    required this.onIntensityChanged,
    required this.onSave,
  });

  final LifeStage lifeStage;
  final Set<GoalArea> goals;
  final AvailableTime availableTime;
  final PreferredIntensity intensity;
  final bool isSaving;
  final ValueChanged<LifeStage> onLifeStageChanged;
  final ValueChanged<GoalArea> onGoalToggled;
  final ValueChanged<AvailableTime> onAvailableTimeChanged;
  final ValueChanged<PreferredIntensity> onIntensityChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _SectionLabel(l10n.lifeStageSectionLabel),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final stage in LifeStage.values)
              ChoiceChip(
                label: Text(lifeStageDisplayName(context, stage)),
                selected: lifeStage == stage,
                onSelected: (_) => onLifeStageChanged(stage),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(l10n.workingOnSectionLabel),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final goal in GoalArea.values)
              FilterChip(
                label: Text(goalAreaDisplayName(context, goal)),
                avatar: Icon(goalAreaIcon(goal), size: 16),
                selected: goals.contains(goal),
                onSelected: (_) => onGoalToggled(goal),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(l10n.availableTimeSectionLabel),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final time in AvailableTime.values)
              ChoiceChip(
                label: Text(availableTimeDisplayName(context, time)),
                selected: availableTime == time,
                onSelected: (_) => onAvailableTimeChanged(time),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionLabel(l10n.preferredIntensitySectionLabel),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final value in PreferredIntensity.values)
              ChoiceChip(
                label: Text(preferredIntensityDisplayName(context, value)),
                selected: intensity == value,
                onSelected: (_) => onIntensityChanged(value),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          onPressed: isSaving ? null : onSave,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.savePreferencesButton),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
