import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/identity/domain/entities/identity_milestone.dart';

void main() {
  test('two milestones with identical fields are equal', () {
    final occurredAt = DateTime.utc(2026, 1, 10);
    final a = IdentityMilestone(
      type: IdentityMilestoneType.levelReached,
      title: 'Reached Level 2',
      iconKey: 'star',
      occurredAt: occurredAt,
    );
    final b = IdentityMilestone(
      type: IdentityMilestoneType.levelReached,
      title: 'Reached Level 2',
      iconKey: 'star',
      occurredAt: occurredAt,
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });

  test('a difference in type, title, iconKey, or date breaks equality', () {
    final base = IdentityMilestone(
      type: IdentityMilestoneType.achievementUnlocked,
      title: 'Unlocked "First Step"',
      iconKey: 'footprint',
      occurredAt: DateTime.utc(2026, 1, 10),
    );

    expect(
      base,
      isNot(
        IdentityMilestone(
          type: IdentityMilestoneType.chainCompleted,
          title: base.title,
          iconKey: base.iconKey,
          occurredAt: base.occurredAt,
        ),
      ),
    );
    expect(
      base,
      isNot(
        IdentityMilestone(
          type: base.type,
          title: 'Unlocked "Getting Started"',
          iconKey: base.iconKey,
          occurredAt: base.occurredAt,
        ),
      ),
    );
    expect(
      base,
      isNot(
        IdentityMilestone(
          type: base.type,
          title: base.title,
          iconKey: 'flag',
          occurredAt: base.occurredAt,
        ),
      ),
    );
    expect(
      base,
      isNot(
        IdentityMilestone(
          type: base.type,
          title: base.title,
          iconKey: base.iconKey,
          occurredAt: DateTime.utc(2026, 1, 11),
        ),
      ),
    );
  });
}
