import 'package:flutter/material.dart';

import '../asset_visual_resolver.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_gradients.dart';

/// Image-slot abstraction for a quest's visual identity. Prime Asset Pack
/// v0.1: [seed] is looked up via [AssetVisualResolver] — a category match
/// (e.g. a suggestion's `fitness/walk_20` visualKey, or a plain quest id
/// carrying no category) renders the bundled illustration; anything
/// unresolved falls back to the original deterministic gradient
/// placeholder with an optional symbolic [icon] overlay. Passing
/// [imageAssetPath] explicitly always wins over the resolver. Either way,
/// callers only ever construct a `QuestVisual`, never an `Image` directly —
/// growing the asset pack or changing the resolution strategy never touches
/// a call site.
class QuestVisual extends StatelessWidget {
  const QuestVisual({
    super.key,
    required this.seed,
    this.imageAssetPath,
    this.icon,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.resolver = const AssetVisualResolver(),
  });

  final String seed;
  final String? imageAssetPath;
  final IconData? icon;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  /// Testability seam — overridable in tests, defaults to the real pack.
  final AssetVisualResolver resolver;

  @override
  Widget build(BuildContext context) {
    final resolvedAssetPath = imageAssetPath ?? resolver.resolve(seed);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: resolvedAssetPath != null
            ? Image.asset(
                resolvedAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppGradients.questPlaceholder(seed)),
      child: icon == null
          ? null
          : Center(
              child: Icon(
                icon,
                size: (height ?? 96) * 0.32,
                color: AppColors.darkTextPrimary.withValues(alpha: 0.28),
              ),
            ),
    );
  }
}
