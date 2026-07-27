import '../../../../core/domain/attribute_type.dart';
import '../../domain/entities/identity_snapshot.dart';

/// A thin projection of [IdentitySnapshot]'s attribute fields — carries the
/// *same already-computed* strongest/weakest through (never recomputes
/// them), so the Identity page's attribute section can never disagree with
/// the snapshot it came from (Phase 12: "No duplicated calculations across
/// widgets"). [percentOf] recomputes its one-line ratio from [xpByAttribute]
/// rather than capturing a closure, so this class stays a plain,
/// value-comparable model.
class AttributeDistribution {
  final Map<AttributeType, int> xpByAttribute;
  final AttributeType? strongest;
  final AttributeType? weakest;

  const AttributeDistribution({
    required this.xpByAttribute,
    required this.strongest,
    required this.weakest,
  });

  factory AttributeDistribution.fromSnapshot(IdentitySnapshot snapshot) {
    return AttributeDistribution(
      xpByAttribute: snapshot.attributeXp,
      strongest: snapshot.strongestAttribute,
      weakest: snapshot.weakestAttribute,
    );
  }

  /// This attribute's share (`0.0`-`1.0`) of total lifetime attribute XP —
  /// the exact same formula as `IdentitySnapshot.attributePercent`, over
  /// the same [xpByAttribute] map this instance was built from.
  double percentOf(AttributeType type) {
    final total = xpByAttribute.values.fold<int>(0, (sum, xp) => sum + xp);
    if (total <= 0) return 0.0;
    return (xpByAttribute[type] ?? 0) / total;
  }

  @override
  bool operator ==(Object other) {
    if (other is! AttributeDistribution) return false;
    if (other.strongest != strongest ||
        other.weakest != weakest ||
        other.xpByAttribute.length != xpByAttribute.length) {
      return false;
    }
    for (final entry in xpByAttribute.entries) {
      if (other.xpByAttribute[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    strongest,
    weakest,
    Object.hashAllUnordered(
      xpByAttribute.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}
