import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../l10n/app_localizations.dart';
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
      appBar: AppBar(
        title: Text(
          detailAsync.value?.chain.title ??
              AppLocalizations.of(context)!.chainFallbackTitle,
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
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
                  hidden ? l10n.hiddenChainTitle : chain.title,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hidden ? l10n.hiddenChainBody : chain.description,
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
            l10n.chainCompletePercent((entry.completionPercent * 100).round()) +
                (entry.isCompleted ? l10n.chainFinishedSuffix : ''),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.stagesHeader, style: theme.textTheme.titleMedium),
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
          AppLocalizations.of(context)!.chainNotFound,
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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.couldntLoadChain,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
