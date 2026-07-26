import '../../../../core/domain/attribute_type.dart';

enum XpSourceType {
  quest,
  chainMilestone,
  achievement,
  boss,
  recoveryQuest,
  manualAdjustment,
}

/// A single, immutable ledger row. docs/architecture.md §15/§16 — append-only,
/// idempotent by [idempotencyKey]; totals are always summed from these rows,
/// never stored as an independently-editable value.
class XpTransaction {
  final String id;
  final XpSourceType sourceType;
  final String sourceId;
  final AttributeType attribute;
  final int baseXp;
  final Map<String, double> modifiersApplied;
  final int finalXp;
  final DateTime createdAt;
  final String idempotencyKey;

  const XpTransaction({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.attribute,
    required this.baseXp,
    required this.modifiersApplied,
    required this.finalXp,
    required this.createdAt,
    required this.idempotencyKey,
  });

  @override
  bool operator ==(Object other) {
    if (other is! XpTransaction) return false;
    return other.id == id &&
        other.sourceType == sourceType &&
        other.sourceId == sourceId &&
        other.attribute == attribute &&
        other.baseXp == baseXp &&
        _mapEquals(other.modifiersApplied, modifiersApplied) &&
        other.finalXp == finalXp &&
        other.createdAt == createdAt &&
        other.idempotencyKey == idempotencyKey;
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceType,
    sourceId,
    attribute,
    baseXp,
    Object.hashAllUnordered(
      modifiersApplied.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    finalXp,
    createdAt,
    idempotencyKey,
  );
}

bool _mapEquals(Map<String, double> a, Map<String, double> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
