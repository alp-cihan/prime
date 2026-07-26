import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Shared page shell for Phase 0 placeholder screens: a title and a body,
/// laid out with the app's spacing scale so every tab starts from the same
/// restrained baseline.
class PrimePageScaffold extends StatelessWidget {
  const PrimePageScaffold({super.key, required this.title, this.body});

  final String title;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.lg),
              if (body != null) Expanded(child: body!),
            ],
          ),
        ),
      ),
    );
  }
}
