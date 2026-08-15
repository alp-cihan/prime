import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/entities/quest_progress.dart';
import '../../../quests/presentation/providers/quest_query_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../providers/today_dashboard_providers.dart';

/// Phase 18 (Today 2.0) — the screen's visual hero: "Today's Mission",
/// [featuredQuestProvider]'s one system-selected priority quest, rendered as
/// a large lifestyle image (via [QuestVisual]'s `visualKey` resolution) with
/// its title overlaid on a dark gradient scrim, and a compact info/CTA
/// footer below. Replaces the earlier `FeaturedQuestCard` — same provider,
/// same navigation target, deliberately larger and image-first per the
/// "user understands what to do within 3 seconds" goal.
///
/// Tapping the card (or its `Begin`/`Continue`/`View` CTA) navigates to the
/// existing [QuestDetailPage]; completion itself always happens there, never
/// from this card. The CTA is a separate, independently-tappable widget
/// ([_HeroCta]) with its own `onPressed` specifically so a later Prime Focus
/// entry point can retarget just that callback without touching this card's
/// layout at all.
class HeroMissionCard extends ConsumerWidget {
  const HeroMissionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questAsync = ref.watch(featuredQuestProvider);

    return questAsync.when(
      data: (quest) => quest == null
          ? const _HeroEmptyState()
          : _HeroMissionContent(quest: quest),
      loading: () => const _HeroSkeleton(),
      error: (error, stackTrace) {
        debugPrint('Featured quest failed to load: $error');
        return _HeroError(onRetry: () => ref.invalidate(featuredQuestProvider));
      },
    );
  }
}

/// Image height for the hero's photo/overlay band. Fixed (not content-sized)
/// so the gradient scrim and overlaid eyebrow/title always sit over real
/// image pixels — everything that can grow with long content (chips,
/// progress, CTA) lives in the plain-flow footer below instead, so a long
/// Turkish title can never force this Stack to overflow.
const _heroImageHeight = 200.0;
const _heroBorderRadius = 28.0;

class _HeroMissionContent extends ConsumerWidget {
  const _HeroMissionContent({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final anchor = ref.watch(
      questOccurrenceAnchorDateProvider(quest.repeatability),
    );
    final progressAsync = ref.watch(
      questProgressForDateProvider(quest.id, anchor),
    );
    final progress = progressAsync.value;
    final completedToday = progress?.isComplete ?? false;
    final baseXp = quest.attributeXpWeights.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final primaryAttribute = _primaryAttribute(quest.attributeXpWeights);

    void openDetail() => context.go(AppRoutes.questDetail(quest.id));

    return GradientSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: _heroBorderRadius,
      onTap: openDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroImageBand(
            quest: quest,
            primaryAttribute: primaryAttribute,
            eyebrow: l10n.mainQuestLabel,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _Chip(
                      label: questDifficultyDisplayName(
                        context,
                        quest.difficulty,
                      ),
                    ),
                    if (primaryAttribute != null)
                      _Chip(
                        icon: attributeIcon(primaryAttribute),
                        label: attributeDisplayName(context, primaryAttribute),
                      ),
                    _Chip(label: '${formatXp(baseXp)} XP'),
                    if (completedToday) _Chip(label: l10n.completedTodayLabel),
                  ],
                ),
                if (!completedToday &&
                    quest.progressType != ProgressType.binary) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _HeroProgress(quest: quest, progress: progress),
                ],
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: _HeroCta(
                    label: _ctaLabel(l10n, quest, progress, completedToday),
                    onPressed: openDetail,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Begin" the first time a quest is touched today (no progress yet, or a
  /// not-yet-completed binary quest), "Continue" once quantity/duration
  /// progress is already underway, "View" once complete — the CTA always
  /// names the action the tap actually performs.
  String _ctaLabel(
    AppLocalizations l10n,
    Quest quest,
    QuestProgress? progress,
    bool completedToday,
  ) {
    if (completedToday) return l10n.ctaView;
    if (quest.progressType == ProgressType.binary) return l10n.heroCtaBegin;
    final started = (progress?.progressValue ?? 0) > 0;
    return started ? l10n.ctaContinue : l10n.heroCtaBegin;
  }
}

/// The image + dark-gradient-scrim + eyebrow/title overlay — isolated from
/// the footer below so its height stays fixed regardless of how much footer
/// content (chips/progress/CTA) there is.
class _HeroImageBand extends StatelessWidget {
  const _HeroImageBand({
    required this.quest,
    required this.primaryAttribute,
    required this.eyebrow,
  });

  final Quest quest;
  final AttributeType? primaryAttribute;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attribute = primaryAttribute;

    return SizedBox(
      height: _heroImageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          QuestVisual(
            // Phase 17.2 — prefer the quest's own visual identity (carried
            // over from the suggestion it was created from, if any); a
            // hand-typed quest has none, so this falls back to its id
            // exactly as before, resolving to the gradient placeholder.
            seed: quest.visualKey ?? quest.id,
            icon: attribute == null ? null : attributeIcon(attribute),
            height: _heroImageHeight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_heroBorderRadius),
            ),
          ),
          // Restrained dark gradient — transparent at the top so the image
          // itself stays visible, opaque enough at the bottom for the
          // overlaid title to stay readable over any photo.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(_heroBorderRadius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quest.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 1.15,
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

/// The whole card already navigates via [GradientSurfaceCard]'s `onTap` —
/// this is a second, independently-tappable target (a filled gradient
/// pill), deliberately its own widget with its own `onPressed` so a future
/// Prime Focus entry point can retarget just this callback without
/// redesigning the hero card around it.
class _HeroCta extends StatelessWidget {
  const _HeroCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: AppGradients.cta,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.darkTextPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

AttributeType? _primaryAttribute(Map<AttributeType, int> weights) {
  if (weights.isEmpty) return null;
  var best = weights.entries.first;
  for (final entry in weights.entries.skip(1)) {
    if (entry.value > best.value) best = entry;
  }
  return best.key;
}

/// Compact quantity/duration readout — mirrors `QuestCard`'s
/// `_CompactProgress`, kept local since it's the only other place Today
/// shows the hero quest's live progress.
class _HeroProgress extends StatelessWidget {
  const _HeroProgress({required this.quest, required this.progress});

  final Quest quest;
  final QuestProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = progress?.progressValue ?? 0.0;
    final target = quest.targetProgress;
    final ratio = target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final unit = quest.progressType == ProgressType.duration
        ? AppLocalizations.of(context)!.minutesUnit
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_formatValue(current)}$unit / ${_formatValue(target)}$unit',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 4,
            backgroundColor: AppColors.darkSurfaceRaised,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

/// No active quest at all — a visually polished empty state (not a plain
/// text-only card) so an empty Today never reads as broken: the same dark
/// hero gradient as the player header, a large glyph, a short headline, and
/// both ways forward (browse a suggestion, or write your own quest).
class _HeroEmptyState extends StatelessWidget {
  const _HeroEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GradientSurfaceCard(
      gradient: AppGradients.hero,
      borderRadius: _heroBorderRadius,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 32,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.heroEmptyHeadline, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.noQuestsYet,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                onPressed: () => context.go(AppRoutes.questNew),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createQuestLabel),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.suggestions),
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: Text(l10n.browseSuggestions),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(_heroBorderRadius),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _HeroError extends StatelessWidget {
  const _HeroError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(_heroBorderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.couldntLoadMainQuest,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.darkTextSecondary),
            const SizedBox(width: 4),
          ],
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
