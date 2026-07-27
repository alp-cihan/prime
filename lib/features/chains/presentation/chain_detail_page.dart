import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import 'chain_icon.dart';
import 'models/chain_with_progress.dart';
import 'providers/chain_query_providers.dart';
import 'widgets/chain_stage_tile.dart';

/// Chain detail — `/you/chains/:chainId`. Shows every stage with its
/// status (locked/unlocked/completed), the current stage highlighted.
class ChainDetailPage extends ConsumerWidget {
  const ChainDetailPage({super.key, required this.chainId});

  final String chainId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(chainDetailProvider(chainId));

    return Scaffold(
      appBar: AppBar(title: Text(detailAsync.value?.chain.title ?? 'Chain')),
      body: detailAsync.when(
        data: (entry) {
          if (entry == null) return const _ChainNotFound();
          return _ChainDetailBody(entry: entry);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Chain detail failed to load: $error');
          return _DetailError(
            onRetry: () => ref.invalidate(chainDetailProvider(chainId)),
          );
        },
      ),
    );
  }
}

class _ChainDetailBody extends StatelessWidget {
  const _ChainDetailBody({required this.entry});

  final ChainWithProgress entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chain = entry.chain;
    final hidden = chain.hiddenUntilStarted && !entry.hasStarted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(chainIconForKey(chain.iconKey), color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  hidden ? 'Hidden Chain' : chain.title,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hidden ? 'Keep playing to discover this chain.' : chain.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: entry.completionPercent,
              minHeight: 6,
              backgroundColor: AppColors.darkSurfaceRaised,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(entry.completionPercent * 100).round()}% complete'
            '${entry.isCompleted ? ' — chain finished' : ''}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Stages', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final stage in entry.stages) ...[
            ChainStageTile(
              stage: stage,
              isCurrent: entry.currentStage?.index == stage.index,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ChainNotFound extends StatelessWidget {
  const _ChainNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          "This chain doesn't exist.",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load this chain.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
