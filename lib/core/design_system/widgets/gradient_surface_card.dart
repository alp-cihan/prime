import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Shared layered-card shell for the Today dashboard's redesigned sections.
/// Pure presentation: a rounded, optionally-gradient surface with an
/// optional tap target. Replaces the ad-hoc `Container`/`Material` pairs
/// each section used to hand-roll so every card reads as one visual system.
class GradientSurfaceCard extends StatelessWidget {
  const GradientSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = 20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      color: gradient == null ? AppColors.darkSurface : null,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
