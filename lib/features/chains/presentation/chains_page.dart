import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/router/app_routes.dart';
import 'models/chain_with_progress.dart';
import 'providers/chain_query_providers.dart';
import 'widgets/chain_card.dart';

/// Chains gallery — reached from the You tab. Pure read model: every
/// number comes from [activeChainsProvider]/[completedChainsProvider],
/// nothing is computed in this widget beyond simple layout.
class ChainsPage extends ConsumerWidget {
  const ChainsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeChainsProvider);
    final completedAsync = ref.watch(completedChainsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chains')),
      body: _buildBody(context, ref, activeAsync, completedAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ChainWithProgress>> activeAsync,
    AsyncValue<List<ChainWithProgress>> completedAsync,
  ) {
    if (activeAsync.isLoading || completedAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (activeAsync.hasError) {
      return _ChainsError(
        error: activeAsync.error!,
        onRetry: () => ref.invalidate(activeChainsProvider),
      );
    }
    if (completedAsync.hasError) {
      return _ChainsError(
        error: completedAsync.error!,
        onRetry: () => ref.invalidate(completedChainsProvider),
      );
    }

    final active = activeAsync.value ?? const <ChainWithProgress>[];
    final completed = completedAsync.value ?? const <ChainWithProgress>[];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Active Chains', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (active.isEmpty)
          const _SectionNote('No active chains yet.')
        else
          for (final entry in active) ...[
            ChainCardRoute(entry: entry),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Completed Chains',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (completed.isEmpty)
          const _SectionNote('No chains completed yet.')
        else
          for (final entry in completed) ...[
            ChainCardRoute(entry: entry),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

/// Bridges a [ChainWithProgress] to navigation — kept separate from
/// `ChainCard` (which stays a pure presentational-plus-provider-read
/// widget) so the card itself never depends on `go_router`.
class ChainCardRoute extends StatelessWidget {
  const ChainCardRoute({super.key, required this.entry});

  final ChainWithProgress entry;

  @override
  Widget build(BuildContext context) {
    return ChainCard(
      entry: entry,
      onTap: () => context.go(AppRoutes.chainDetail(entry.chain.id)),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary),
    );
  }
}

class _ChainsError extends StatelessWidget {
  const _ChainsError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    debugPrint('Chains failed to load: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load your chains.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong loading chains. Please try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
