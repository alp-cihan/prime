import 'package:flutter/material.dart';

/// Grayscale-dominant surfaces with a single accent color, per the
/// dark-first, restrained visual language in docs/architecture.md.
abstract final class AppColors {
  static const Color accent = Color(0xFF5E8BFF);

  static const Color darkBackground = Color(0xFF0A0A0B);
  static const Color darkSurface = Color(0xFF17171A);
  static const Color darkSurfaceRaised = Color(0xFF212126);
  static const Color darkBorder = Color(0xFF2C2C31);
  static const Color darkTextPrimary = Color(0xFFF2F2F3);
  static const Color darkTextSecondary = Color(0xFFA0A0A8);

  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceRaised = Color(0xFFF1F1F3);
  static const Color lightBorder = Color(0xFFE1E1E4);
  static const Color lightTextPrimary = Color(0xFF141416);
  static const Color lightTextSecondary = Color(0xFF5C5C64);
}
