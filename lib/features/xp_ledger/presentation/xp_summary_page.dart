import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/attribute_type.dart';
import '../domain/services/level_curve.dart';
import 'providers/xp_ledger_providers.dart';
import 'widgets/attribute_xp_tile.dart';
import 'widgets/level_progress_card.dart';

/// Global XP summary — lives at the existing `/you` destination (see
/// `you_page.dart`), the shell location docs/architecture.md already
/// designates for the player-profile hub. Every number here is derived
/// fresh from [totalXpProvider]/[xpByAttributeProvider] (ledger-backed) and
/// the pure [LevelCurve] — nothing is cached or stored separately.
class XpSummaryPage extends ConsumerWidget {
  const XpSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalXpAsync = ref.watch(totalXpProvider);
    final byAttributeAsync = ref.watch(xpByAttributeProvider);

    return PrimePageScaffold(
      title: 'You',
      body: _buildBody(context, ref, totalXpAsync, byAttributeAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> totalXpAsync,
    AsyncValue<Map<AttributeType, int>> byAttributeAsync,
  ) {
    if (totalXpAsync.isLoading || byAttributeAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (totalXpAsync.hasError) {
      return _XpSummaryError(
        error: totalXpAsync.error!,
        onRetry: () => ref.invalidate(totalXpProvider),
      );
    }
    if (byAttributeAsync.hasError) {
      return _XpSummaryError(
        error: byAttributeAsync.error!,
        onRetry: () => ref.invalidate(xpByAttributeProvider),
      );
    }

    final totalXp = totalXpAsync.value ?? 0;
    final byAttribute = byAttributeAsync.value ?? const <AttributeType, int>{};
    const levelCurve = LevelCurve();
    final levelProgress = levelCurve.levelForTotalXp(totalXp, base: 100);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        LevelProgressCard(levelProgress: levelProgress, totalXp: totalXp),
        const SizedBox(height: AppSpacing.lg),
        Text('XP by attribute', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final type in AttributeType.values) ...[
          AttributeXpTile(attribute: type, xp: byAttribute[type] ?? 0),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _XpSummaryError extends StatelessWidget {
  const _XpSummaryError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // See quests_page.dart's `_QuestsError` for why the raw error is never
    // rendered directly (a ProviderException's toString() embeds its whole
    // stack trace, which caused a real layout overflow).
    debugPrint('XP summary failed to load: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load your XP.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong loading your XP. Please try again.',
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
