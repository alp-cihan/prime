import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_gradients.dart';

/// Image-slot abstraction for a quest's visual identity. No bundled art
/// exists yet, so this renders a deterministic gradient placeholder seeded
/// by [seed] (typically the quest id) with an optional symbolic [icon]
/// overlay. Passing [imageAssetPath] in a future asset phase swaps in the
/// real artwork without any change to callers or business logic — they
/// only ever construct a `QuestVisual`, never an `Image` directly.
class QuestVisual extends StatelessWidget {
  const QuestVisual({
    super.key,
    required this.seed,
    this.imageAssetPath,
    this.icon,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final String seed;
  final String? imageAssetPath;
  final IconData? icon;
  final double? height;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: imageAssetPath != null
            ? Image.asset(imageAssetPath!, fit: BoxFit.cover)
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.questPlaceholder(seed),
                ),
                child: icon == null
                    ? null
                    : Center(
                        child: Icon(
                          icon,
                          size: (height ?? 96) * 0.32,
                          color: AppColors.darkTextPrimary.withValues(
                            alpha: 0.28,
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}
