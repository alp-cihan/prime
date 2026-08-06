import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_info.dart';
import '../../../core/app_restart_scope.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/failure.dart';
import '../../../core/localization/app_locale_option.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import 'providers/clear_data_controller.dart';

/// Minimal Settings — reached from the You tab. Phase 14: restart onboarding,
/// app version, a local-data explanation, a strongly-confirmed clear-all
/// action, and an About/licenses entry.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(clearDataControllerProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        if (!context.mounted) return;
        ref.read(clearDataControllerProvider.notifier).reset();
        // The use case already deleted and reopened every Hive box empty —
        // this is what actually resets every provider/controller in the app
        // (including the onboarding flag's own provider) so nothing is left
        // pointing at stale, pre-clear state.
        AppRestartScope.restart(context);
      } else if (next.hasError) {
        debugPrint('Clear local data failed: ${next.error}');
      }
    });

    final clearState = ref.watch(clearDataControllerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader(l10n.generalSectionHeader),
          _SettingsTile(
            icon: Icons.replay_outlined,
            title: l10n.restartOnboardingTitle,
            subtitle: l10n.restartOnboardingSubtitle,
            onTap: () => context.push(AppRoutes.onboarding),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.auto_awesome_outlined,
            title: l10n.suggestionPreferencesTitle,
            subtitle: l10n.suggestionPreferencesSubtitle,
            onTap: () => context.push(AppRoutes.suggestionsPreferences),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(l10n.languageSectionHeader),
          const _LanguageSelector(),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(l10n.aboutSectionHeader),
          _SettingsInfoTile(
            icon: Icons.info_outline,
            title: l10n.versionLabel,
            subtitle: AppInfo.displayVersion,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.localDataExplanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n.licensesTitle,
            subtitle: l10n.licensesSubtitle,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Prime',
              applicationVersion: AppInfo.displayVersion,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(l10n.dataSectionHeader),
          if (clearState.hasError) ...[
            _ClearDataError(failure: clearState.error),
            const SizedBox(height: AppSpacing.sm),
          ],
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            iconColor: Theme.of(context).colorScheme.error,
            title: l10n.clearAllDataTitle,
            subtitle: l10n.clearAllDataSubtitle,
            isLoading: clearState.isLoading,
            onTap: clearState.isLoading
                ? null
                : () => _confirmClear(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearAllDataDialogTitle),
        content: Text(l10n.clearAllDataDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteEverything),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    ref.read(clearDataControllerProvider.notifier).clear();
  }
}

/// The Sistem dili / Türkçe / English language selector. A plain
/// `SegmentedButton` over [AppLocaleOption] — [LocaleController] persists the
/// choice immediately and `app.dart`'s `MaterialApp.router` watches it
/// directly, so picking a segment here updates the whole UI live, with no
/// restart.
class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(localeControllerProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<AppLocaleOption>(
        segments: [
          ButtonSegment(
            value: AppLocaleOption.system,
            label: Text(l10n.languageSystemOption),
          ),
          ButtonSegment(
            value: AppLocaleOption.turkish,
            label: Text(l10n.languageTurkishOption),
          ),
          ButtonSegment(
            value: AppLocaleOption.english,
            label: Text(l10n.languageEnglishOption),
          ),
        ],
        selected: {current},
        onSelectionChanged: (selection) => ref
            .read(localeControllerProvider.notifier)
            .setOption(selection.first),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.accent),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.darkTextSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  const _SettingsInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearDataError extends StatelessWidget {
  const _ClearDataError({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final message = failure is Failure
        ? (failure as Failure).message
        : AppLocalizations.of(context)!.couldntClearData;

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
