import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Shared circular progress indicator with an optional centered child.
/// Pure presentation — the caller supplies an already-computed 0..1 ratio;
/// replaces the duplicated `Stack`-of-`CircularProgressIndicator` markup
/// the player header and daily-progress card each used to hand-roll.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.strokeWidth = 6,
    this.trackColor,
    this.progressColor,
    this.child,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? trackColor;
  final Color? progressColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: trackColor ?? AppColors.darkSurfaceRaised,
            valueColor: AlwaysStoppedAnimation(
              progressColor ?? AppColors.accent,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
