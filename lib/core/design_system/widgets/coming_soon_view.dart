import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// A restrained "not built yet" placeholder for a tab/section that exists in
/// the navigation shell but has no content of its own this phase — e.g.
/// Story and Journal. Deliberately not a blank [Scaffold] body: an empty
/// title-only screen reads as broken (Phase 13's "no dead-end screens"), so
/// this gives the same calm, single-accent-color treatment every other empty
/// state in the app uses, without implying any new feature or mechanic.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.darkTextSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
