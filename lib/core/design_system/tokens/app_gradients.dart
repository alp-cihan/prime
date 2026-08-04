import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Restrained blue-to-purple gradients for exactly two cinematic surfaces
/// (the hero player header and the featured-quest CTA) — every other
/// surface in the app stays flat [AppColors.darkSurface] per the
/// single-accent, grayscale-dominant UI rule. Deliberately dark and
/// low-contrast rather than vivid, to avoid reading as decoration.
abstract final class AppGradients {
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF23264A), Color(0xFF1A1C33), AppColors.darkSurface],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accent, AppColors.accentSecondary],
  );

  /// Deterministic duotone placeholder for a quest's [QuestVisual] slot,
  /// seeded by the quest id so the same quest always gets the same look
  /// until a real bundled image replaces it.
  static LinearGradient questPlaceholder(String seed) {
    final hash = seed.hashCode.abs();
    final begin = hash.isEven ? Alignment.topLeft : Alignment.topRight;
    final end = hash.isEven ? Alignment.bottomRight : Alignment.bottomLeft;
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        AppColors.accent.withValues(alpha: 0.5),
        AppColors.accentSecondary.withValues(alpha: 0.35),
        AppColors.darkSurface,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }
}
