import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_info.dart';
import '../../../core/app_restart_scope.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/failure.dart';
import '../../../core/router/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader('General'),
          _SettingsTile(
            icon: Icons.replay_outlined,
            title: 'Restart Onboarding',
            subtitle: 'See the intro and starter quests again',
            onTap: () => context.push(AppRoutes.onboarding),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.auto_awesome_outlined,
            title: 'Suggestion Preferences',
            subtitle: 'Life stage, goals, time, and pace for Suggestions',
            onTap: () => context.push(AppRoutes.suggestionsPreferences),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('About'),
          const _SettingsInfoTile(
            icon: Icons.info_outline,
            title: 'Version',
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
              'All your data is stored only on this device, using local '
              'storage (Hive). Nothing is sent to a server. Uninstalling '
              'the app, or clearing local data below, permanently erases it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Licenses',
            subtitle: 'Open-source software used by Prime',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Prime',
              applicationVersion: AppInfo.displayVersion,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader('Data'),
          if (clearState.hasError) ...[
            _ClearDataError(failure: clearState.error),
            const SizedBox(height: AppSpacing.sm),
          ],
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'Clear all local data',
            subtitle: 'Permanently erase every quest, XP, and unlock',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all local data?'),
        content: const Text(
          'This permanently deletes every quest, all progress, all XP, and '
          'every achievement and chain you have unlocked — on this device '
          'only. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    ref.read(clearDataControllerProvider.notifier).clear();
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
        : "Couldn't clear local data. Please try again.";

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
