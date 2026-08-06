import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/catalog/starter_quest_template.dart';
import 'providers/onboarding_completion_controller.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/starter_template_tile.dart';

/// docs/architecture.md-adjacent, Phase 14: a lightweight, skippable,
/// resumable explanation of what Prime is, shown full-screen and outside the
/// 5-tab shell (same placement as Focus Mode) — either as the very first
/// screen (first launch, gated by the router's redirect) or pushed on top of
/// the shell ("Restart Onboarding" in Settings).
///
/// "Resumable" here means going Back and forth between slides never loses
/// the starter-template selections made on the last one — both live in this
/// single widget's state for the lifetime of one onboarding session. Nothing
/// is persisted mid-flow; only the final "finish" action writes anything.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _selectedTemplateIds = <String>{};
  int _page = 0;

  List<OnboardingSlideContent> _slides(AppLocalizations l10n) => [
    OnboardingSlideContent(
      icon: Icons.auto_awesome_outlined,
      title: l10n.onboardingSlide1Title,
      body: l10n.onboardingSlide1Body,
    ),
    OnboardingSlideContent(
      icon: Icons.checklist_outlined,
      title: l10n.onboardingSlide2Title,
      body: l10n.onboardingSlide2Body,
    ),
    OnboardingSlideContent(
      icon: Icons.bolt_outlined,
      title: l10n.onboardingSlide3Title,
      body: l10n.onboardingSlide3Body,
    ),
    OnboardingSlideContent(
      icon: Icons.trending_up,
      title: l10n.onboardingSlide4Title,
      body: l10n.onboardingSlide4Body,
    ),
    OnboardingSlideContent(
      icon: Icons.person_outline,
      title: l10n.onboardingSlide5Title,
      body: l10n.onboardingSlide5Body,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(onboardingCompletionControllerProvider, (
      previous,
      next,
    ) {
      if (next.hasValue && next.value != null) {
        if (!context.mounted) return;
        context.go(AppRoutes.today);
        ref.read(onboardingCompletionControllerProvider.notifier).reset();
      } else if (next.hasError) {
        debugPrint('Onboarding finish failed: ${next.error}');
      }
    });

    final controllerState = ref.watch(onboardingCompletionControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final slides = _slides(l10n);
    final pageCount = slides.length + 1;
    final isLastPage = _page == pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.md,
                  top: AppSpacing.xs,
                ),
                child: TextButton(
                  onPressed: controllerState.isLoading ? null : _skip,
                  child: Text(l10n.skip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final slide in slides) OnboardingSlide(content: slide),
                  _StarterTemplatesStep(
                    selectedIds: _selectedTemplateIds,
                    onToggle: (id) => setState(() {
                      if (!_selectedTemplateIds.remove(id)) {
                        _selectedTemplateIds.add(id);
                      }
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  if (controllerState.hasError) ...[
                    _OnboardingError(failure: controllerState.error),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < pageCount; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? AppColors.accent
                                : AppColors.darkSurfaceRaised,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      if (_page > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controllerState.isLoading
                                ? null
                                : _goBack,
                            child: Text(l10n.back),
                          ),
                        ),
                      if (_page > 0) const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                          onPressed: controllerState.isLoading
                              ? null
                              : (isLastPage ? _finish : _goNext),
                          child: controllerState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isLastPage
                                      ? (_selectedTemplateIds.isEmpty
                                            ? l10n.getStarted
                                            : l10n.addSelectedGetStarted)
                                      : l10n.next,
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _goBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _skip() {
    ref.read(onboardingCompletionControllerProvider.notifier).finish(const []);
  }

  void _finish() {
    final selected = starterQuestTemplateCatalog
        .where((t) => _selectedTemplateIds.contains(t.id))
        .toList();
    ref.read(onboardingCompletionControllerProvider.notifier).finish(selected);
  }
}

class _StarterTemplatesStep extends StatelessWidget {
  const _StarterTemplatesStep({
    required this.selectedIds,
    required this.onToggle,
  });

  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.wantHeadStart, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.pickQuestsOptional,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final template in starterQuestTemplateCatalog) ...[
            StarterTemplateTile(
              template: template,
              selected: selectedIds.contains(template.id),
              onTap: () => onToggle(template.id),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(AppRoutes.suggestions),
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(l10n.browseMoreSuggestions),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingError extends StatelessWidget {
  const _OnboardingError({required this.failure});

  final Object? failure;

  @override
  Widget build(BuildContext context) {
    final message = failure is Failure
        ? (failure as Failure).message
        : AppLocalizations.of(context)!.somethingWentWrong;

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
