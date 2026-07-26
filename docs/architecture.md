# LIFE OS v2 — Architecture with Integrated RPG Progression System

> "My real life is the game. My actions are quests. My consistency generates XP. My identity levels up."

This document supersedes and extends `life-os-architecture.md`. It does not replace the product's calm/premium DNA — it gives that DNA a progression engine underneath it. **No code yet**, per instructions.

---

## 0. What Changes, What Doesn't (read this first)

### Unchanged from v1
- Core philosophy: identity over habits, consistency over perfection, one-glance clarity, offline-first speed.
- Clean Architecture (`presentation → domain ← data`), pure-Dart domain layer.
- Hive as local source of truth, Supabase as sync mirror.
- Riverpod (`@riverpod` codegen), feature-scoped repositories/controllers.
- GoRouter shell + routes from v1 (extended, not replaced).
- Forgiveness-token streak system (now feeds Recovery Quests, see §11).
- One-accent-color, dark-first, grayscale-dominant design system.
- 5-tab bottom nav (`Today · Missions/Quests · Goals/Story · Journal · You`).

### Modified
- "Missions" are now the daily/repeatable subset of a unified **Quest System**. The word "Mission" survives only as UI copy for daily items — internally, everything is a `Quest`.
- "Goals" become **Main Story Quests** with **Quest Chains** (chapters/milestones).
- "Identity System" becomes the **Identity Ledger** — statements are now backed by computed evidence, not just affirmation streaks.
- Today dashboard hierarchy is rebuilt around Player Header → Score → Main Quest → Daily Quests → Attribute Growth → Boss/Story → Identity Evidence.
- `DailyScore` stays, but is now explicitly decoupled from XP (§12).

### Added (net-new)
- `PlayerProfile`, `Attribute`/`AttributeProgress`, `XpTransaction` ledger, `QuestChain`/`QuestChapter`, `BossChallenge`, `Achievement`, `Title`, `LevelUpEvent`, `RecoveryQuest`, `Season`.
- XP economy with anti-abuse multipliers (§3).
- Level curve + rank tiers (§4).
- Boss System for hard real-life stretches (§7).
- Level-up interaction pattern (§14).

### Must be locked before Phase 0
1. Final XP formula constants (base XP per quest type, multiplier ranges) — tunable later, but the *shape* of the formula must be frozen so the ledger schema doesn't migrate mid-build.
2. The 8 attributes and their names — these are referenced everywhere (missions, achievements, radar-equivalent UI).
3. Rank tier names/boundaries.
4. Whether `DailyScore` and `PlayerXP` are visually shown together on Today (recommendation: yes, but visually distinct — ring vs. bar, see §13).
5. Idempotency-key strategy for XP transactions (recommendation in §17) — this is a schema decision, expensive to change post-launch.

---

## 1. Revised Product Principles

All v1 principles hold, plus:

| Principle | Meaning |
|---|---|
| **XP is truth, totals are cache** | Every XP-affecting event is an immutable ledger entry. Displayed totals are always *derived*, never hand-edited. |
| **Progression never regresses** | XP is never subtracted. Bad days lower *Daily Score*, never *Player XP* or attribute levels. |
| **The game is real, so the UI must stay real** | No fantasy avatars, no loot, no currency, no gacha mechanics. Progression is expressed through numbers, restrained color, and typography — the same visual vocabulary as the rest of the app, not a separate "game skin." |
| **Progressive disclosure over stat overload** | The player never sees all 8 attributes, all quests, and a boss bar at once. Today shows 3 attributes max; the rest is one tap away. |

---

## 2. Revised Information Architecture

```
LIFE OS
│
├── Today (Home)                 — Player Header, Score, Main Quest, Daily Quests, Attribute Growth, Boss/Story card, Identity Evidence
├── Quests                        — replaces "Missions" tab
│   ├── Daily / Weekly / Monthly / Side (filterable list)
│   └── Quest Detail
├── Story                         — replaces "Goals" tab
│   ├── Main Story Quests (Quest Chains)
│   │   └── Chain Detail (chapters, next objective)
│   └── Epic Quests (standalone, non-chained big efforts)
├── Journal
├── You (Profile hub)             — replaces plain "Settings" as tab landing
│   ├── Player Profile             — level, title, attributes, rank
│   ├── Attribute Detail
│   ├── Achievements
│   ├── Titles
│   ├── Identity Ledger
│   ├── Life Areas                 — retained, now cross-linked to attributes
│   ├── Weekly / Monthly Review
│   └── Settings
├── Bosses                        — reached from Today card or Story; not its own tab
├── Focus Mode                    — outside shell, unchanged in spirit
└── Level-Up Overlay              — modal/queue, not a screen
```

Nav stays 5 tabs (`Today · Quests · Story · Journal · You`) — RPG depth lives *inside* `You` and contextual cards, not as new top-level chrome. This is the single most important restraint decision in this revision.

---

## 3. XP Economy

### 3.1 Formula

```
earnedXp = round(
  baseXp
  × difficultyMultiplier
  × completionRatio
  × consistencyMultiplier
  × qualityMultiplier
) × firstCompletionBonus
```

Diminishing returns and daily caps are applied *after* this, as a clamp — never as a negative multiplier (never punitive, just "no further gain").

### 3.2 Ranges

| Factor | Range | Notes |
|---|---|---|
| `baseXp` (Daily Quest) | 20–40 | Set per quest at creation, weighted by category default |
| `baseXp` (Weekly Quest) | 80–150 | |
| `baseXp` (Monthly Quest) | 200–400 | |
| `baseXp` (Side Quest) | 15–30 | |
| `baseXp` (Epic Quest) | 300–800 | One-time, awarded on final completion |
| `baseXp` (Main Story milestone) | 500–2000 | Awarded per milestone, not per chain |
| `baseXp` (Recovery Quest) | 30–60 | Deliberately capped low, see §11 anti-farming |
| `difficultyMultiplier` | 0.5 (Trivial) – 1.6 (Very Hard) | Set once per quest, editable only in quest edit mode (not per-completion, to prevent gaming) |
| `completionRatio` | 0.0 – 1.0 | For quantity/duration quests only; binary quests are always 1.0 or not awarded |
| `consistencyMultiplier` | 1.0 – 1.3 | +0.02 per consecutive day completing *this specific quest*, capped at +0.3 (day 15+) |
| `qualityMultiplier` | 0.8 – 1.2 | Optional self-rating (1-5 stars) on completion; defaults to 1.0 if skipped |
| `firstCompletionBonus` | ×1.25 (quests), flat +10% ledger note (chain milestones) | Applied once per quest lifetime |

### 3.3 Anti-Abuse Mechanics

- **Daily cap per mission/quest**: `baseXp × difficultyMultiplier × 2` regardless of repeat count or manual re-logging.
- **Diminishing returns on repeats**: 2nd completion of the same repeatable quest same day → ×0.5 further; 3rd+ → ×0.25. Encourages one meaningful log per quest per day, not spam-tapping.
- **Trivial-quest ceiling**: total daily XP earnable from quests marked `Trivial` difficulty is capped app-wide (e.g. 100 XP/day), so creating 40 tiny quests can't outpace real effort.
- **Quantity/duration honesty friction**: these quest types require entering the actual value or using the in-app timer — no single-tap "complete" for a 2-hour coding session. Manual entries flagged as statistical outliers (e.g. "10 hours coding" logged in 30 seconds) silently drop `qualityMultiplier` to 0.8 rather than blocking the entry — no accusatory UI, just a quiet normalization.
- **Server-authoritative recompute**: Supabase Edge Function periodically recomputes attribute/level totals from the XP transaction ledger and reconciles client-cached projections — catches any client-side tampering without an on-device "anti-cheat" scan (would be paranoid and un-premium).

---

## 4. Level System

### 4.1 Global Player Level Curve

Incremental XP required to go from level `n` to `n+1`:

```
xpToNext(n) = floor(100 × n^1.5)
```

This is deliberately sub-exponential: early levels feel fast, growth smooths out rather than exploding, and the game supports **years** of play without a wall.

| Level | XP to reach next level | Approx. cumulative XP to reach this level |
|---|---|---|
| 1 | 100 | 0 |
| 5 | 1,118 | ≈2,200 |
| 10 | 3,162 | ≈12,600 |
| 20 | 8,944 | ≈71,500 |
| 30 | 16,431 | ≈197,000 |
| 50 | 35,355 | ≈707,000 |
| 100 | 100,000 | ≈4,000,000 |

At a realistic ~250–400 XP/day of genuine engagement, level 10 arrives in ~1–2 months, level 20 in under a year, level 30 around 1.5–2 years, level 50+ becomes a multi-year aspiration, and level 100 is intentionally near-mythical — a "Legend" is someone who used the app meaningfully for the better part of a decade. That asymptote is a feature, not a bug: it keeps the ceiling honest.

### 4.2 Attribute Level Curve

Same shape, smaller base (attributes split XP across 8 pools):
```
attrXpToNext(n) = floor(30 × n^1.5)
```

### 4.3 Ranks (Global Level → Rank)

| Rank | Level range |
|---|---|
| Initiate | 1–9 |
| Apprentice | 10–19 |
| Builder | 20–29 |
| Specialist | 30–39 |
| Vanguard | 40–49 |
| Master | 50–64 |
| Ascendant | 65–84 |
| Legend | 85+ |

Rank is display-only metadata derived from level — not a separate progression track.

---

## 5. Quest System

`Quest` replaces `Mission` as the domain concept. UI copy stays casual ("Today's Missions" header is fine) but the underlying model is unified.

### 5.1 Quest Types

| Type | Cadence | UI treatment |
|---|---|---|
| Daily Quest | resets daily | Today list, checkbox/progress row |
| Weekly Quest | resets weekly | Quests tab, "This Week" filter |
| Monthly Quest | resets monthly | Quests tab, "This Month" filter |
| Side Quest | one-off, no cadence | Quests tab, "Side Quests" filter |
| Epic Quest | one-off, large | Story tab, standalone card |
| Main Story Quest | belongs to a Quest Chain | Story tab, chapter view |
| Repeatable Quest | internal representation for Daily/Weekly | not user-facing as a distinct type |
| Recovery Quest | system-generated after a lapse | surfaced as a gentle banner, not a nag |

### 5.2 Quest Fields

Title, description, `QuestType`, `QuestDifficulty`, XP reward config (base + attribute weights), linked `IdentityStatement` id(s), linked `LifeAreaType`, `ProgressType` (binary/quantity/duration), current/target progress, deadline (nullable), `questChainId` (nullable), `prerequisiteQuestIds`, `QuestCompletionState`, `failureBehavior` (`expire`, `carryOver`, `convertToRecovery`), optional bonus reward, repeatability rule (`none`, `daily`, `weekly`, `customCron`).

### 5.3 Multi-Attribute Rewards

A single quest completion can distribute XP across multiple attributes in one transaction batch (still one logical "event," multiple ledger rows — see §16):

```
Workout        → Health +70, Strength +40, Discipline +25
Coding         → Career +70, Knowledge +35, Discipline +20
Reading        → Knowledge +60, Discipline +15
Family Time    → Relationships +50, Mindfulness +10
Saving Money   → Finance +60, Discipline +20
```

These are **default weight templates** per quest category, editable per-quest at creation, not hardcoded — so a user can rebalance if e.g. they consider Reading more of a Mindfulness activity than Knowledge.

---

## 6. Quest Chains (Main Story)

A `QuestChain` is what "Goals" become. Example:

```
Main Story: Become a Professional AI Engineer
  Chapter 1 — Core coursework           [complete]
  Chapter 2 — Three portfolio projects  [2/3]
  Chapter 3 — Internship                [locked, prereq: Ch.2]
  Chapter 4 — Ship a production app     [locked]
  Chapter 5 — First AI engineering role [locked]
```

Each `QuestChapter` is itself a `Quest` (type = Main Story Quest) with `prerequisiteQuestIds` pointing at the prior chapter. Chain-level view shows: chapters list, completed-step count, next objective (auto-derived: first incomplete chapter with satisfied prerequisites), overall progress %, story summary (short, editorial-typography paragraph), and "why it matters" (carried over from v1's Goal.whyItMatters, now living on the chain root).

---

## 7. Boss System

A `BossChallenge` represents a real, bounded hard period — not a fantasy monster. Visually: a single restrained progress bar (not a health-bar-red aesthetic — uses the app's one accent color), a duration countdown, and a compact phase tracker.

### 7.1 Fields
Title, description, `startDate`/`endDate`, `progressCurrent`/`progressTarget` (a "damage" pool filled by linked quest completions), `List<BossPhase>`, `requiredQuestIds`, `optionalQuestIds`, `List<BossModifier>` (e.g. "XP +10% during this boss" to keep motivation high during hard weeks — the *only* place a temporary XP multiplier is allowed, and it's always positive, never punitive), `finalReward` (a `Reward` — typically a Title unlock), `postBossReflection` (short journal-style prompt shown once, on completion).

### 7.2 Example
```
Exam Week (Boss)
  Duration: 7 days
  Required: 5 study sessions, 200 practice questions, sleep ≥7h × 5 nights, attend all exams
  Optional: 1 review session per subject
  Progress bar fills as required quests complete
  Final reward: "Iron Mind" title progress + reflection prompt
```

Bosses are opt-in and user-creatable from a template list (Exam Week, Weight-Loss Plateau, App Launch, Job Interview, Financial Reset, Recovery Month, Summer Cut, custom) — never auto-imposed, since only the user knows when a hard period is starting.

---

## 8. Achievements

`Achievement` categories: Consistency, Health, Strength, Knowledge, Career, Finance, Relationships, Exploration, Identity, Recovery, Hidden.

Fields: title, description, icon (single-tone, metallic/tonal treatment — never a colorful sticker), category, `AchievementRarity` (Common/Uncommon/Rare/Epic/Legendary), unlock rule (declarative, evaluated server-side against the XP ledger — see §17), progress (nullable, for trackable-but-not-yet-unlocked achievements shown as a subtle progress ring), `unlockedAt`, XP reward, optional title reward, `isHidden`.

Rarity is expressed only through a thin metallic border treatment and label weight — not through size or saturation, to avoid a "gacha" feel.

Examples (as specified): *First Step, Momentum, Iron Mind, The Builder, Returner, Quiet Consistency* — all kept as unlock-rule definitions evaluated against ledger aggregates (e.g. "Iron Mind" = 100 completed quests where `linkedAttribute == Discipline`).

---

## 9. Titles

`Title` is a cosmetic unlock, granted by specific achievements, chain completions, or boss victories. Only one `EquippedTitle` at a time. Appears in four places only: Player Profile, Today's Player Header, Weekly Review header, Level-Up overlay — deliberately not sprinkled everywhere, to keep it a quiet flex rather than a nameplate.

Examples: The Beginner, The Consistent, Builder, Engineer, Scholar, Athlete, Iron Mind, Reliable, Pathfinder, Master of Discipline, Ascendant, Legend.

---

## 10. Identity Ledger

`IdentityStatement` (from v1) now computes an `IdentityStrength` score from linked evidence rather than being a bare affirmation:

```
IdentityStrength = f(
  recentEvidenceCount (last 30 days, weighted higher),
  lifetimeEvidenceCount,
  consistencyOfEvidence (spread across weeks, not clustered),
  averageDifficultyOfLinkedCompletions
)
```

`IdentityEvidence` is generated automatically whenever a linked quest/attribute-XP event occurs — it's a read model over the XP ledger and quest completions, not a separately-entered thing. Example evidence surfaced in UI: *"42 workouts completed · 18 weeks with 3+ workouts · 120,000 Health XP earned"* for "I am an athlete." This directly satisfies "do not reduce identity to affirmations alone" — the statement is a claim, the ledger is the proof.

---

## 11. Streaks & Recovery (RPG-Integrated)

Forgiveness-token model from v1 is retained exactly, now wired into the quest/XP system:

- **Protected miss**: forgiveness token spent → no Recovery Quest triggered, streak preserved, shown as a faded dot (not red).
- **Streak break (no tokens left)**: triggers a system-generated `RecoveryQuest` ("Return after missing three days") instead of just resetting silently. Completing it:
  - Restores the *display* streak counter to a "return streak" (separate from all-time longest streak, which is never erased).
  - Grants **comeback XP** — a modest, one-time bonus (capped, non-repeatable per lapse event) on top of normal quest XP, to reward the *return* specifically.
  - Anti-farming: comeback XP can only be earned once per lapse (a lapse = streak break event with a unique id); intentionally breaking streaks to farm comeback bonuses is a net XP loss vs. just maintaining the streak, by design of the multiplier math.
- **Lifetime Consistency Score**: a slow-moving, ledger-derived metric (not the same as Daily Score) shown only in Monthly Review and Player Profile — the "this is who you've been over time" number.
- Language throughout recovery flows is explicitly non-shame-based: no "you failed," always "you're back" framing.

---

## 12. Daily Score vs. Player XP vs. everything else (explicit definitions)

| Metric | Definition | Volatility | Can decrease? |
|---|---|---|---|
| **Daily Score** (0–100) | How well *today* matched the plan (v1 formula, unchanged) | Resets daily | Yes, daily |
| **Weekly Consistency** | % of planned quests completed this week | Resets weekly | Yes, weekly |
| **Lifetime XP** | Sum of all XP transactions, ever | Monotonic | **Never** |
| **Attribute XP / Level** | Sum of XP transactions filtered by attribute | Monotonic | **Never** |
| **Identity Strength** | Derived score from ledger evidence (§10) | Slow-moving | Can drift down slowly if evidence goes stale, never "punished" sharply |
| **Quest Completion Rate** | % of quests completed vs. planned, rolling window (7/30/90-day) | Rolling | Yes, as a rolling average |

These are never combined into one meaningless composite number — this was an explicit requirement and is treated as load-bearing: each metric answers a different question, and the UI never conflates them into a single blended "life score."

---

## 13. Revised Today Dashboard UX

Hierarchy (progressive disclosure, one dominant element per section, no more than 3 attributes shown):

1. **Player Header** — small monogram/portrait avatar (abstract, not fantasy), name, Global Level badge, Equipped Title, thin XP progress bar to next level. Compact, single row.
2. **Today Score** — the calm 0–100 ring from v1, unchanged placement/prominence. Visually distinct from the XP bar above it (ring vs. bar; accent color vs. neutral) so the two metrics are never visually conflated.
3. **Main Quest card** — exactly one system-selected priority quest (highest difficulty × deadline-proximity, or user-pinned), with progress and a direct "Focus" button into Focus Mode.
4. **Active Daily Quests** — compact list, same visual language as v1's Mission list.
5. **Attribute Growth** — top 3 attributes by recent XP gained (not all 8), shown as small labeled bars with a "+N XP today" chip. Tap → full Attribute Detail (all 8, radar-style, reuses v1's `RadarChart` component).
6. **Active Boss / Story card** — one compact progress card, only rendered if a boss or an in-progress chain milestone is active; otherwise this section collapses entirely (no empty-state clutter).
7. **Identity Evidence line** — single sentence, editorial typeface, e.g. *"You've shown up for your body 42 times — that's who you are now."* Rotates among active identity statements.

Nothing here adds a section beyond v1's Today screen — attribute growth and the boss/story card *replace* the old "Life Areas strip" and "Motivation card" slots respectively, so total screen density stays flat even though meaning deepens.

---

## 14. Level-Up Experience

- Trigger: any XP transaction that crosses a level threshold enqueues a `LevelUpEvent`.
- Presentation: modal overlay route (`/level-up`), auto-dismissible in <2s of inactivity or one tap, queued if multiple fire at once (never stacks visually).
- Content: new level number (large numeral, single accent-color glow — no particle explosion), thin XP bar animating fill → reset, unlocked title/feature chip *only if one was unlocked this level*, optional short haptic (medium impact) + optional subtle sound (mutable in settings).
- **Major milestones** (rank-up levels: 10, 20, 30, 40, 50, 65, 85) get a fuller version: same visual language, slightly longer hold (3–4s), shows new Rank name.
- Never blocks navigation — user can dismiss instantly and keep moving; this is a celebration, not a gate.

---

## 15. Domain Entities (pure Dart, no Flutter/Hive/Supabase/Riverpod imports)

```dart
// ── Player ──────────────────────────────────────────────
class PlayerProfile {
  final String id;
  final String displayName;
  final String? portraitAssetOrMonogram;
  final int globalLevel;
  final int currentXpIntoLevel;
  final int xpRequiredForNextLevel;
  final int totalLifetimeXp;
  final PlayerRank rank;
  final String? equippedTitleId;
  final DateTime createdAt;
  final String currentSeasonId;
  final List<String> unlockedAchievementIds;
  final List<String> activeMainQuestIds;
}

enum PlayerRank { initiate, apprentice, builder, specialist, vanguard, master, ascendant, legend }

class PlayerLevel {
  final int level;
  final int xpToNext;          // xpToNext(n) = floor(100 * n^1.5)
  final int cumulativeXpAtStart;
}

class LevelUpEvent {
  final String id;
  final int fromLevel;
  final int toLevel;
  final bool isRankMilestone;
  final String? unlockedTitleId;
  final DateTime occurredAt;
  final bool acknowledged;
}

// ── Attributes ─────────────────────────────────────────
enum AttributeType { health, strength, discipline, knowledge, career, finance, relationships, mindfulness }

class Attribute {
  final AttributeType type;
  final String displayName;
}

class AttributeProgress {
  final AttributeType type;
  final int level;
  final int currentXpIntoLevel;
  final int xpRequiredForNextLevel;
  final int lifetimeXp;
  final List<String> linkedQuestIds;
  final List<String> linkedGoalChainIds;
  final List<String> linkedAchievementIds;
}

// ── XP Ledger ───────────────────────────────────────────
enum XpSourceType { quest, chainMilestone, achievement, boss, recoveryQuest, manualAdjustment }

class XpTransaction {
  final String id;                 // uuid
  final XpSourceType sourceType;
  final String sourceId;           // quest id, chain milestone id, etc.
  final AttributeType attribute;
  final int baseXp;
  final Map<String, double> modifiersApplied; // {"difficulty":1.3,"consistency":1.1,...}
  final int finalXp;
  final DateTime createdAt;
  final String idempotencyKey;     // deterministic, e.g. hash(sourceId+attribute+completionDate)
}

// ── Quests ──────────────────────────────────────────────
enum QuestType { daily, weekly, monthly, side, epic, mainStory, repeatable, recovery }
enum QuestDifficulty { trivial, easy, normal, hard, veryHard }
enum ProgressType { binary, quantity, duration }
enum QuestCompletionState { notStarted, inProgress, complete, expired, converted }
enum FailureBehavior { expire, carryOver, convertToRecovery }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestDifficulty difficulty;
  final Map<AttributeType, int> attributeXpWeights; // e.g. {health:70, strength:40, discipline:25}
  final List<String> linkedIdentityStatementIds;
  final LifeAreaType linkedArea;
  final ProgressType progressType;
  final double currentProgress;
  final double targetProgress;
  final DateTime? deadline;
  final String? questChainId;
  final List<String> prerequisiteQuestIds;
  final QuestCompletionState state;
  final FailureBehavior failureBehavior;
  final Reward? optionalReward;
  final String? repeatabilityRule; // null | "daily" | "weekly" | cron-like string
}

class QuestProgress {
  final String questId;
  final DateTime date;
  final double progressValue;
  final bool isComplete;
  final String? notes;
  final int? qualityRating; // 1-5, optional
  final Duration? timeSpent;
}

// ── Quest Chains (Main Story) ───────────────────────────
class QuestChain {
  final String id;
  final String title;              // "Become a Professional AI Engineer"
  final String storySummary;
  final String whyItMatters;
  final List<String> chapterQuestIdsInOrder;
  final double overallProgressPercent; // derived
  final DateTime? deadline;
  final bool isArchived;
}

class QuestChapter {
  final String id;
  final String questChainId;
  final int order;
  final String title;
  final String questId;            // the underlying Quest (type=mainStory)
}

// ── Bosses ──────────────────────────────────────────────
class BossChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final double progressCurrent;
  final double progressTarget;
  final List<BossPhase> phases;
  final List<String> requiredQuestIds;
  final List<String> optionalQuestIds;
  final List<BossModifier> modifiers;
  final Reward? finalReward;
  final String? postBossReflectionPrompt;
  final bool isComplete;
}

class BossPhase {
  final String id;
  final String title;
  final double thresholdPercent; // e.g. phase 2 starts at 33% progress
  final bool isComplete;
}

class BossModifier {
  final String description;    // "XP +10% during this boss"
  final double xpMultiplierDelta; // always >= 0
}

// ── Achievements & Titles ────────────────────────────────
enum AchievementCategory { consistency, health, strength, knowledge, career, finance, relationships, exploration, identity, recovery, hidden }
enum AchievementRarity { common, uncommon, rare, epic, legendary }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final String unlockRuleId;       // references a declarative rule evaluated server-side
  final int xpReward;
  final String? titleRewardId;
  final bool isHidden;
}

class AchievementProgress {
  final String achievementId;
  final double progressPercent;    // 0.0-1.0, null-able if not trackable pre-unlock
  final DateTime? unlockedAt;
}

class Title {
  final String id;
  final String name;
  final String? unlockedByAchievementId;
  final String? unlockedByChainId;
  final String? unlockedByBossId;
}

class EquippedTitle {
  final String titleId;
  final DateTime equippedAt;
}

// ── Identity Ledger ───────────────────────────────────────
class IdentityStatement {
  final String id;
  final String statement;
  final LifeAreaType relatedArea;
  final List<AttributeType> relatedAttributes;
  final bool isActive;
}

class IdentityEvidence {
  final String identityStatementId;
  final DateTime windowStart;
  final DateTime windowEnd;
  final int evidenceCount;
  final String summaryLine;         // "42 workouts completed · 18 weeks with 3+..."
}

class IdentityStrength {
  final String identityStatementId;
  final double score;               // 0.0-1.0, derived (§10 formula)
  final DateTime computedAt;
}

// ── Recovery ────────────────────────────────────────────
class RecoveryQuest {
  final String id;
  final String triggeringLapseId;   // unique per streak-break event
  final DateTime offeredAt;
  final bool isComplete;
  final int comebackXpAwarded;      // capped, one-time per lapseId
}

// ── Rewards & Seasons ─────────────────────────────────────
class Reward {
  final int? xp;
  final String? titleId;
  final String? achievementId;
}

class Season {
  final String id;
  final String name;                // e.g. "2026 · Season 1"
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}
```

---

## 16. XP Transaction Ledger — Why & How

**Rule: totals are always projections, never stored as the source of truth.** `AttributeProgress.lifetimeXp` and `PlayerProfile.totalLifetimeXp` are Hive-cached *derived* values, rebuilt by summing `XpTransaction` rows — never directly mutated.

A single quest completion that rewards multiple attributes writes **one `XpTransaction` per attribute**, all sharing a common `sourceId` (the `QuestProgress` completion event id) but each with its own `idempotencyKey` = `hash(questId + attribute + date + sourceId)`. This makes it safe to:
- Recompute all totals from scratch at any time (audit/debug/rebalance).
- Detect and silently drop duplicate writes during sync (§17).
- Explain "why did I get this XP" to the user if ever needed (transparency builds trust in the number).

---

## 17. Offline-First Sync — RPG Extensions

Builds on v1's outbox + Supabase Realtime pattern (§8 of v1 doc), with RPG-specific rules:

| Entity | Sync rule |
|---|---|
| `XpTransaction` | **Append-only, idempotent by `idempotencyKey`.** Upsert on `idempotencyKey` unique constraint in Postgres — duplicate pushes from retry/offline-queue are no-ops, never double-credited. **Never LWW** — these are events, not editable state. |
| `Quest` / `QuestChain` definitions | Standard LWW on `updatedAt`, same as v1 goals/missions. |
| `QuestProgress` (completion events) | Append-only per date, idempotent by `(questId, date)` composite key — a second completion log for the same quest/day updates progress value but does not re-trigger reward XP transactions (those already exist and are immutable). |
| `Achievement` unlocks | Idempotent by `(achievementId, userId)` unique constraint — unlock rule evaluated server-side (Edge Function) on ledger writes, not client-side, so two devices completing the qualifying action concurrently can't double-unlock or double-reward. |
| `LevelUpEvent` | Derived, not synced directly — recomputed from `totalLifetimeXp` projection on each device; `acknowledged` flag is the only mutable/synced field (LWW). |
| Concurrent device completions | Because reward-granting is idempotent and keyed off the ledger (not client state), completing the same quest from two offline devices before sync just merges into the same set of transactions once `idempotencyKey`s collide — no double reward, no manual conflict resolution needed. |

**Server-authoritative reconciliation**: a scheduled Edge Function periodically recomputes `AttributeProgress`/`PlayerProfile` projections from the full ledger and pushes corrections if a client's cached projection drifted (e.g. from a bug or interrupted sync) — self-healing without ever touching the ledger itself.

---

## 18. Riverpod State Layering (RPG additions)

Following v1's pattern (`xRepositoryProvider → xUseCaseProviders → xControllerProvider`, plus derived `Provider`s):

- `playerProfileProvider` (`AsyncNotifier`) — profile CRUD, equip title.
- `xpLedgerProvider` — read-only paginated access to transactions (for audit/history views), plus `recordXpTransactionUseCase`.
- `attributeProgressProvider` (`family` by `AttributeType`) — derived from ledger, cached.
- `activeQuestsProvider` (`family` by `QuestType` filter).
- `questChainProvider` (`family` by chain id) — chapters + derived overall progress.
- `bossChallengeProvider` (`family` by boss id, plus `activeBossesProvider` list).
- `achievementsProvider` — unlocked + in-progress, derived from ledger + rule evaluation cache.
- `titlesProvider` — owned titles + `equippedTitleProvider`.
- `levelUpQueueProvider` — a simple `StateNotifier<Queue<LevelUpEvent>>` that the `/level-up` overlay route consumes and pops.
- `identityLedgerProvider` (`family` by statement id) — evidence + strength score, derived.
- `recoveryStateProvider` — active lapse / recovery quest offer, if any.

**No single "RPG god provider."** Each concept is independently testable and independently invalidated — e.g. completing a quest invalidates `activeQuestsProvider`, `attributeProgressProvider(affectedAttributes)`, and `xpLedgerProvider`, but does *not* touch `achievementsProvider` unless a rule threshold was actually crossed (checked, not blindly invalidated).

---

## 19. Routing (extended)

```
/                        → Today
/quests                  → Quest list (filterable: daily/weekly/monthly/side)
/quests/:id              → Quest detail
/story                   → Main Story overview (chains + epics)
/story/:chainId           → Chain detail (chapters, next objective)
/bosses/:id                → Boss detail
/achievements             → Achievement gallery
/titles                    → Title collection + equip
/profile                  → Player Profile
/profile/attributes/:type → Attribute detail
/identity                 → Identity Ledger list
/identity/evidence/:id    → Evidence detail for one statement
/journal                  → unchanged from v1
/journal/entry/:date       → unchanged
/reviews/weekly            → unchanged
/reviews/monthly           → unchanged
/focus                     → unchanged — full-screen, outside shell
/level-up                  → modal overlay route, outside shell, queue-driven
/settings/...               → unchanged from v1
```

`ShellRoute` now wraps `Today · Quests · Story · Journal · You`. `/profile`, `/achievements`, `/titles`, `/identity` are pushed from within the `You` tab, not separate shell destinations — keeps nav count at 5.

---

## 20. Testing Strategy (RPG-specific additions)

| Layer | What to test |
|---|---|
| XP formula | Pure unit tests on `earnedXp` calculation across the full multiplier range, including clamp/cap behavior — highest-value tests in the whole app, since a formula bug directly mis-rewards users. |
| Level curve | Unit tests verifying `xpToNext(n)` monotonicity and the level-from-cumulative-XP inverse function agree with each other (no off-by-one at level boundaries). |
| Ledger idempotency | Integration tests simulating duplicate transaction pushes (offline retry, concurrent devices) → assert totals unaffected. |
| Achievement rule engine | Table-driven tests per rule (e.g. "Iron Mind" rule against a synthetic ledger fixture). |
| Recovery/comeback XP | Test that comeback XP cannot be earned twice for the same `lapseId`, and that intentionally breaking a streak is net XP-negative vs. maintaining it. |
| Sync reconciliation | Test that server-recomputed projections converge with client cache after a simulated drift. |
| Widget/golden | Level-up overlay, Player Header, Attribute bars — visual regression, since restraint (no confetti, one accent color) is a design requirement that's easy to accidentally violate in a future PR. |

---

## 21. Revised Build Roadmap

**Phase 0 — Foundation**
Design tokens, `life_os_ui` component kit, GoRouter shell (5 tabs), Hive setup, dark theme.

**Phase 1 — Quest Core Loop + XP Ledger**
`Quest`/`QuestProgress` data+domain+presentation, `XpTransaction` ledger (local, idempotency keys), `PlayerProfile` + `AttributeProgress` with real derived totals. *This phase is the entire game engine — get the ledger right here, everything else reads from it.*

**Phase 2 — Dashboard, Levels, Recognition**
Today dashboard (full §13 hierarchy), level curve + `LevelUpEvent` queue + overlay, Titles, Achievements (rule engine, local evaluation first), forgiveness-token streaks, Recovery Quests + comeback XP.

**Phase 3 — Story**
Goals → `QuestChain`/`QuestChapter` migration, Story tab UI, chain progress derivation.

**Phase 4 — Depth Layer**
Boss System, Life Areas (cross-linked to attributes), Identity Ledger (evidence + strength scoring).

**Phase 5 — Reflection**
Journal, Weekly Review (now includes title/level context in header), Monthly Review (adds Lifetime Consistency Score, attribute trend charts).

**Phase 6 — Sync & Platform**
Supabase schema (all v2 entities), sync engine with §17's idempotency rules, Edge Function reconciliation + achievement rule evaluation, auth, notifications (add: level-up-adjacent nudges, boss deadline reminders — still low-frequency), home screen widgets (Score ring + top quest, optionally level/title).

**Phase 7 — Polish, Balance, Harden**
XP economy balancing pass (real usage data), animation/haptics pass on level-up and quest completion, golden tests, accessibility audit, store prep.

---

## 22. Closing Restraint Checklist (carried into every future phase)

No fantasy weapons · no cartoon avatar · no coin/currency economy · no loot boxes · no fake scarcity · no XP loss ever · no red "failure" screens · no dark patterns · no more than 3 attributes shown at once on Today · no separate "game skin" — RPG elements use the same type system, spacing, and single accent color as the rest of the app.

The test for every future RPG-adjacent screen: *would this look at home in Linear or Apple Fitness, or does it look like a mobile game?* If the latter, simplify until it doesn't.

---

*Waiting for approval before Phase 0 code.*