import '../entities/achievement.dart';
import '../entities/achievement_trigger.dart';

/// Phase 10's built-in, code-defined achievement catalog — the single
/// source of truth for every unlockable achievement. Deliberately not
/// persisted or user-editable (Phase 10 non-goal: custom user-created
/// achievements): the catalog is data, but it is *code*, versioned with the
/// app like `QuestDifficulty`'s multiplier table. Extending it means adding
/// an entry here; nothing else needs to change to make a new achievement
/// evaluable, as long as its trigger already exists in [AchievementTrigger].
///
/// [Achievement.sortOrder] intentionally matches declaration order here for
/// readability, but the two are independent — `AchievementEvaluationService`
/// sorts by [Achievement.sortOrder], never by list position.
const achievementCatalog = <Achievement>[
  Achievement(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your first quest.',
    iconKey: 'footprint',
    trigger: AchievementTrigger.totalQuestCompletions,
    threshold: 1,
    rewardXp: 20,
    sortOrder: 0,
  ),
  Achievement(
    id: 'getting_started',
    title: 'Getting Started',
    description: 'Complete 5 quests.',
    iconKey: 'flag',
    trigger: AchievementTrigger.totalQuestCompletions,
    threshold: 5,
    rewardXp: 30,
    sortOrder: 1,
  ),
  Achievement(
    id: 'consistent',
    title: 'Consistent',
    description: 'Complete a quest on 3 consecutive days.',
    iconKey: 'calendar',
    trigger: AchievementTrigger.consecutiveDaysCompleted,
    threshold: 3,
    rewardXp: 40,
    sortOrder: 2,
  ),
  Achievement(
    id: 'experienced',
    title: 'Experienced',
    description: 'Reach player level 5.',
    iconKey: 'star',
    trigger: AchievementTrigger.playerLevelReached,
    threshold: 5,
    rewardXp: 50,
    sortOrder: 3,
  ),
  Achievement(
    id: 'xp_hunter',
    title: 'XP Hunter',
    description: 'Reach 1,000 lifetime XP.',
    iconKey: 'bolt',
    trigger: AchievementTrigger.lifetimeXpReached,
    threshold: 1000,
    rewardXp: 50,
    sortOrder: 4,
  ),
  Achievement(
    id: 'specialist',
    title: 'Specialist',
    description: 'Reach 500 XP in a single attribute.',
    iconKey: 'target',
    trigger: AchievementTrigger.attributeXpReached,
    threshold: 500,
    // No `attributeType` pinned — "any one" attribute reaching 500
    // satisfies this (see the trigger's own doc for why that's the max,
    // not the sum, across attributes).
    rewardXp: 40,
    sortOrder: 5,
  ),
  Achievement(
    id: 'challenger',
    title: 'Challenger',
    description: 'Complete a Hard or Very Hard quest.',
    iconKey: 'shield',
    trigger: AchievementTrigger.hardOrAboveQuestCompleted,
    threshold: 1,
    // A deliberate hidden pick — exercises the "hidden until unlocked" path
    // the spec asks for, and thematically fits a surprise challenge.
    hiddenUntilUnlocked: true,
    rewardXp: 30,
    sortOrder: 6,
  ),
];
