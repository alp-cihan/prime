import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/domain/attribute_type.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/attribute_distribution.dart';

/// "Build/Balance" section — a compact 8-axis radar chart of the player's
/// attribute distribution, custom-painted (no chart package) so it stays a
/// deterministic, presentation-only view of already-existing
/// [AttributeDistribution] data. Each axis is normalized against the
/// player's own highest attribute (not share-of-total, which is what the
/// Attribute Profile section above already shows) so the shape reads as a
/// legible "balance" — a perfect octagon means every attribute carries
/// equal weight relative to the strongest one.
class IdentityBalanceSection extends StatelessWidget {
  const IdentityBalanceSection({super.key, required this.distribution});

  final AttributeDistribution distribution;

  bool get _isEmpty => distribution.xpByAttribute.values.every((xp) => xp <= 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.buildBalanceHeader, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              Semantics(
                label: _semanticsLabel(context, l10n),
                child: ExcludeSemantics(
                  child: _AttributeRadarChart(distribution: distribution),
                ),
              ),
              if (_isEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.buildBalanceEmptyHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _semanticsLabel(BuildContext context, AppLocalizations l10n) {
    if (_isEmpty) return l10n.buildBalanceEmptyHint;
    final parts = AttributeType.values.map((type) {
      final percent = (distribution.percentOf(type) * 100).round();
      return '${attributeDisplayName(context, type)} ${l10n.percentValue(percent)}';
    });
    return '${l10n.buildBalanceHeader}: ${parts.join(', ')}';
  }
}

class _AttributeRadarChart extends StatelessWidget {
  const _AttributeRadarChart({required this.distribution});

  final AttributeDistribution distribution;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth.clamp(180.0, 260.0);
        return SizedBox(
          width: side,
          height: side,
          child: CustomPaint(
            painter: _RadarPainter(
              distribution: distribution,
              iconColor:
                  DefaultTextStyle.of(context).style.color ??
                  AppColors.darkTextSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.distribution, required this.iconColor});

  final AttributeDistribution distribution;
  final Color iconColor;

  static const _ringFractions = [0.33, 0.66, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    final outerRadius = maxRadius - 24;
    if (outerRadius <= 0) return;

    final gridPaint = Paint()
      ..color = AppColors.darkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final axisPoints = List.generate(
      AttributeType.values.length,
      (i) => _pointAt(center, i, outerRadius),
    );

    for (final fraction in _ringFractions) {
      final ringPoints = List.generate(
        AttributeType.values.length,
        (i) => _pointAt(center, i, outerRadius * fraction),
      );
      canvas.drawPath(_polygonPath(ringPoints), gridPaint);
    }

    for (final point in axisPoints) {
      canvas.drawLine(center, point, gridPaint);
    }

    final maxXp = distribution.xpByAttribute.values.fold<int>(
      0,
      (max, xp) => xp > max ? xp : max,
    );

    if (maxXp > 0) {
      final dataPoints = List.generate(AttributeType.values.length, (i) {
        final type = AttributeType.values[i];
        final xp = distribution.xpByAttribute[type] ?? 0;
        final ratio = (xp / maxXp).clamp(0.0, 1.0);
        return _pointAt(center, i, outerRadius * ratio);
      });

      final fillPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = AppColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final dotPaint = Paint()..color = AppColors.accent;

      final dataPath = _polygonPath(dataPoints);
      canvas.drawPath(dataPath, fillPaint);
      canvas.drawPath(dataPath, strokePaint);
      for (final point in dataPoints) {
        canvas.drawCircle(point, 3, dotPaint);
      }
    }

    for (var i = 0; i < AttributeType.values.length; i++) {
      final iconPoint = _pointAt(center, i, outerRadius + 16);
      _paintIcon(canvas, attributeIcon(AttributeType.values[i]), iconPoint);
    }
  }

  Offset _pointAt(Offset center, int index, double radius) {
    final angle =
        -math.pi / 2 + index * (2 * math.pi / AttributeType.values.length);
    return center + Offset(math.cos(angle), math.sin(angle)) * radius;
  }

  Path _polygonPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    return path;
  }

  void _paintIcon(Canvas canvas, IconData icon, Offset center) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 15,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor,
        ),
      )
      ..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.distribution != distribution ||
      oldDelegate.iconColor != iconColor;
}
