import 'package:flutter/material.dart';

/// Maps [Achievement.iconKey] to a single-tone glyph — per
/// docs/architecture.md §8, achievement icons are "single-tone,
/// metallic/tonal treatment — never a colorful sticker", so this
/// deliberately returns a bare outlined [IconData] for the caller to tint
/// with the design system's own accent/neutral colors, never a pre-colored
/// asset. An unrecognized key (e.g. a future catalog entry whose icon this
/// mapping hasn't been extended for yet) falls back to a generic trophy
/// glyph rather than throwing — a missing icon is a cosmetic gap, not a
/// reason to crash the Achievements page.
IconData achievementIconForKey(String iconKey) {
  switch (iconKey) {
    case 'footprint':
      return Icons.directions_walk;
    case 'flag':
      return Icons.flag_outlined;
    case 'calendar':
      return Icons.calendar_today_outlined;
    case 'star':
      return Icons.star_outline;
    case 'bolt':
      return Icons.bolt_outlined;
    case 'target':
      return Icons.track_changes_outlined;
    case 'shield':
      return Icons.shield_outlined;
    default:
      return Icons.emoji_events_outlined;
  }
}
