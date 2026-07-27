import 'package:flutter/material.dart';

/// Maps [Chain.iconKey] to a single-tone glyph — same restraint rule as
/// `achievement_icon.dart` (docs/architecture.md §8's "single-tone,
/// metallic/tonal treatment, never a colorful sticker" applies equally
/// here). An unrecognized key falls back to a generic book/story glyph
/// rather than throwing.
IconData chainIconForKey(String iconKey) {
  switch (iconKey) {
    case 'book':
      return Icons.auto_stories_outlined;
    case 'map':
      return Icons.map_outlined;
    case 'compass':
      return Icons.explore_outlined;
    case 'flag':
      return Icons.flag_outlined;
    default:
      return Icons.auto_stories_outlined;
  }
}
