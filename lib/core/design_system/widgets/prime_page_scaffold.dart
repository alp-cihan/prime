import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Shared page shell for Phase 0 placeholder screens: a title and a body,
/// laid out with the app's spacing scale so every tab starts from the same
/// restrained baseline.
class PrimePageScaffold extends StatelessWidget {
  const PrimePageScaffold({
    super.key,
    required this.title,
    this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final Widget? body;
  final Widget? floatingActionButton;

  /// Optional trailing widgets shown alongside the title — e.g. a Phase 16
  /// "browse suggestions" entry point on the Quests tab. `null` (the
  /// default) reproduces the exact pre-Phase-16 layout.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (body != null) Expanded(child: body!),
            ],
          ),
        ),
      ),
    );
  }
}
