import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../domain/entities/identity_milestone.dart';
import '../domain/entities/identity_snapshot.dart';
import 'models/attribute_distribution.dart';
import 'models/lifetime_statistics.dart';
import 'providers/identity_query_providers.dart';
import 'widgets/identity_attribute_section.dart';
import 'widgets/identity_lifetime_section.dart';
import 'widgets/identity_profile_summary.dart';
import 'widgets/identity_timeline.dart';

/// Identity Profile — reached from the You tab. Every section is derived
/// entirely from [identitySnapshotProvider] (directly, or via its thin
/// [attributeDistributionProvider]/[lifetimeStatisticsProvider]
/// projections) and [recentMilestonesProvider] — nothing here is computed
/// by the widget itself.
class IdentityPage extends ConsumerWidget {
  const IdentityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(identitySnapshotProvider);
    final attributesAsync = ref.watch(attributeDistributionProvider);
    final statisticsAsync = ref.watch(lifetimeStatisticsProvider);
    final milestonesAsync = ref.watch(recentMilestonesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Identity')),
      body: _buildBody(
        context,
        ref,
        snapshotAsync,
        attributesAsync,
        statisticsAsync,
        milestonesAsync,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<IdentitySnapshot> snapshotAsync,
    AsyncValue<AttributeDistribution> attributesAsync,
    AsyncValue<LifetimeStatistics> statisticsAsync,
    AsyncValue<List<IdentityMilestone>> milestonesAsync,
  ) {
    final loading =
        snapshotAsync.isLoading ||
        attributesAsync.isLoading ||
        statisticsAsync.isLoading ||
        milestonesAsync.isLoading;
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error =
        snapshotAsync.error ??
        attributesAsync.error ??
        statisticsAsync.error ??
        milestonesAsync.error;
    if (error != null) {
      debugPrint('Identity page failed to load: $error');
      return _IdentityError(
        onRetry: () {
          ref.invalidate(identitySnapshotProvider);
          ref.invalidate(attributeDistributionProvider);
          ref.invalidate(lifetimeStatisticsProvider);
          ref.invalidate(recentMilestonesProvider);
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        IdentityProfileSummary(snapshot: snapshotAsync.value!),
        const SizedBox(height: AppSpacing.lg),
        IdentityAttributeSection(distribution: attributesAsync.value!),
        const SizedBox(height: AppSpacing.lg),
        IdentityLifetimeSection(statistics: statisticsAsync.value!),
        const SizedBox(height: AppSpacing.lg),
        IdentityTimeline(milestones: milestonesAsync.value!),
      ],
    );
  }
}

class _IdentityError extends StatelessWidget {
  const _IdentityError({required this.onRetry});

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
              "Couldn't load your identity profile.",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Something went wrong. Please try again.',
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
