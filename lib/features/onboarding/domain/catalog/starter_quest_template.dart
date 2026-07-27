import '../../../../core/domain/attribute_type.dart';
import '../../../quests/domain/entities/quest.dart';
import '../../../quests/domain/entities/repeatability.dart';

/// A code-defined suggestion offered during onboarding — not a domain
/// entity of its own. Selecting one creates a perfectly normal, user-owned
/// [Quest] through the existing quest application layer
/// (`CreateStarterQuestsUseCase` → `CreateQuestUseCase`); nothing about a
/// template is ever persisted directly.
class StarterQuestTemplate {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<AttributeType, int> attributeXpWeights;
  final ProgressType progressType;
  final double targetProgress;
  final Repeatability repeatability;

  const StarterQuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.attributeXpWeights,
    required this.progressType,
    required this.targetProgress,
    this.repeatability = Repeatability.daily,
  });
}

/// Deliberately small (Phase 14: "a small, code-defined template catalog") —
/// ordinary daily habits that need no explanation, covering a spread of
/// attributes and all three progress types so the onboarding offer reads as
/// representative of the app, not a random sample.
const starterQuestTemplateCatalog = <StarterQuestTemplate>[
  StarterQuestTemplate(
    id: 'drink_water',
    title: 'Drink water',
    description: 'Stay hydrated through the day.',
    type: QuestType.daily,
    difficulty: QuestDifficulty.easy,
    attributeXpWeights: {AttributeType.health: 25},
    progressType: ProgressType.quantity,
    targetProgress: 8,
  ),
  StarterQuestTemplate(
    id: 'read_20_minutes',
    title: 'Read for 20 minutes',
    description: 'A short daily reading habit.',
    type: QuestType.daily,
    difficulty: QuestDifficulty.easy,
    attributeXpWeights: {AttributeType.knowledge: 30},
    progressType: ProgressType.duration,
    targetProgress: 20,
  ),
  StarterQuestTemplate(
    id: 'walk_15_minutes',
    title: 'Walk for 15 minutes',
    description: 'A short walk, any time of day.',
    type: QuestType.daily,
    difficulty: QuestDifficulty.easy,
    attributeXpWeights: {AttributeType.health: 25},
    progressType: ProgressType.duration,
    targetProgress: 15,
  ),
  StarterQuestTemplate(
    id: 'plan_tomorrow',
    title: 'Plan tomorrow',
    description: 'A few minutes to set up tomorrow before today ends.',
    type: QuestType.daily,
    difficulty: QuestDifficulty.easy,
    attributeXpWeights: {AttributeType.discipline: 20},
    progressType: ProgressType.binary,
    targetProgress: 1,
  ),
  StarterQuestTemplate(
    id: 'complete_a_workout',
    title: 'Complete a workout',
    description: 'Any real physical effort counts.',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: {AttributeType.health: 25, AttributeType.strength: 15},
    progressType: ProgressType.binary,
    targetProgress: 1,
  ),
];
