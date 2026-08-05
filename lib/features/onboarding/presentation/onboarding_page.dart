import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/failure.dart';
import '../../../core/router/app_routes.dart';
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

  static const _slides = [
    OnboardingSlideContent(
      icon: Icons.auto_awesome_outlined,
      title: 'Welcome to Prime',
      body:
          'Prime turns your real habits into visible progress — no fantasy, '
          'no clutter, just your own effort tracked honestly.',
    ),
    OnboardingSlideContent(
      icon: Icons.checklist_outlined,
      title: 'Quests are the things you do',
      body:
          'A daily habit, a one-off task, a bigger goal — each one is a '
          'Quest. Completing it makes progress.',
    ),
    OnboardingSlideContent(
      icon: Icons.bolt_outlined,
      title: 'Progress earns XP',
      body:
          'Completing a quest earns XP toward the attribute it is about — '
          'Health, Discipline, Knowledge, and more.',
    ),
    OnboardingSlideContent(
      icon: Icons.trending_up,
      title: 'Attributes build your level',
      body:
          'XP adds up into a Level that only ever goes up — a simple, '
          'honest record of consistency over time.',
    ),
    OnboardingSlideContent(
      icon: Icons.person_outline,
      title: 'Find your story in You',
      body:
          'Achievements, Quest Chains, and your Identity Profile all live in '
          'the You tab — derived automatically from what you do. Nothing to '
          'set up.',
    ),
  ];

  /// The final page count: every info slide, plus one starter-template step.
  int get _pageCount => _slides.length + 1;

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
    final isLastPage = _page == _pageCount - 1;

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
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final slide in _slides) OnboardingSlide(content: slide),
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
                      for (var i = 0; i < _pageCount; i++)
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
                            child: const Text('Back'),
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
                                            ? 'Get Started'
                                            : 'Add Selected & Get Started')
                                      : 'Next',
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Want a head start?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pick any quests you want to start with — entirely optional. '
            "You can always add your own instead, or later.",
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
              label: const Text('Browse more suggestions'),
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
        : 'Something went wrong. Please try again.';

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
