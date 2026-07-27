import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// One informational slide's content — plain data, rendered by
/// [OnboardingSlide].
class OnboardingSlideContent {
  final IconData icon;
  final String title;
  final String body;

  const OnboardingSlideContent({
    required this.icon,
    required this.title,
    required this.body,
  });
}

/// A single onboarding slide: one icon, one short title, one short
/// paragraph. Deliberately static — no animation beyond the [PageView]'s own
/// default swipe transition (Phase 14: "no elaborate animations").
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.content});

  final OnboardingSlideContent content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(content.icon, size: 64, color: AppColors.accent),
          const SizedBox(height: AppSpacing.xl),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            content.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
