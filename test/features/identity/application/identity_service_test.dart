import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/entities/achievement.dart';
import 'package:prime/features/achievements/domain/entities/achievement_trigger.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/chains/domain/entities/chain.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/identity/application/services/identity_service.dart';
import 'package:prime/features/identity/domain/entities/identity_milestone.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';

import '../../../support/fake_repositories.dart';

XpTransaction _questTx({
  required String questId,
  required String dateKey,
  int repeatIndex = 0,
  AttributeType attribute = AttributeType.health,
  int finalXp = 100,
  required DateTime createdAt,
}) {
  final sourceId = '$questId|$dateKey|$repeatIndex';
  return XpTransaction(
    id: '$sourceId|${attribute.name}',
    sourceType: XpSourceType.quest,
    sourceId: sourceId,
    attribute: attribute,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: createdAt,
    idempotencyKey: '$sourceId|${attribute.name}',
  );
}

XpTransaction _achievementRewardTx({
  required String achievementId,
  int finalXp = 20,
  required DateTime createdAt,
}) {
  final sourceId = '$achievementId|reward';
  return XpTransaction(
    id: sourceId,
    sourceType: XpSourceType.achievement,
    sourceId: sourceId,
    attribute: AttributeType.discipline,
    baseXp: finalXp,
    modifiersApplied: const {},
    finalXp: finalXp,
    createdAt: createdAt,
    idempotencyKey: sourceId,
  );
}

const _achievements = <Achievement>[
  Achievement(
    id: 'first_step',
    title: 'First Step',
    description: 'Complete your first quest.',
    iconKey: 'footprint',
    trigger: AchievementTrigger.totalQuestCompletions,
    threshold: 1,
    sortOrder: 0,
  ),
];

const _chains = <Chain>[
  Chain(
    id: 'chain1',
    title: 'Morning Routine',
    description: 'A short chain.',
    iconKey: 'sunrise',
    questIds: ['q1', 'q2'],
    sortOrder: 0,
  ),
];

void main() {
  late FakeXpLedgerRepository ledger;
  late FakeAchievementUnlockRepository unlockRepository;
  late FakeChainProgressRepository chainProgressRepository;
  late IdentityService service;

  setUp(() {
    ledger = FakeXpLedgerRepository();
    unlockRepository = FakeAchievementUnlockRepository();
    chainProgressRepository = FakeChainProgressRepository();
    service = IdentityService(
      xpLedgerRepository: ledger,
      achievementUnlockRepository: unlockRepository,
      chainProgressRepository: chainProgressRepository,
      achievements: _achievements,
      chains: _chains,
    );
  });

  group('buildSnapshot — empty profile', () {
    test('every counter is zero and dates are null', () async {
      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );

      expect(snapshot.currentLevel, 1);
      expect(snapshot.lifetimeXp, 0);
      expect(snapshot.attributeXp, isEmpty);
      expect(snapshot.completedQuests, 0);
      expect(snapshot.completedChains, 0);
      expect(snapshot.unlockedAchievements, 0);
      expect(snapshot.currentStreakDays, 0);
      expect(snapshot.firstQuestDate, isNull);
      expect(snapshot.latestActivityDate, isNull);
    });

    test('recentMilestones is empty', () async {
      expect(await service.recentMilestones(), isEmpty);
    });
  });

  group('buildSnapshot — populated profile', () {
    test('lifetimeXp and attributeXp include quest and reward XP', () async {
      ledger.byKey['a'] = _questTx(
        questId: 'q1',
        dateKey: '2026-01-10',
        attribute: AttributeType.health,
        finalXp: 100,
        createdAt: DateTime.utc(2026, 1, 10),
      );
      ledger.byKey['b'] = _achievementRewardTx(
        achievementId: 'first_step',
        finalXp: 20,
        createdAt: DateTime.utc(2026, 1, 10),
      );

      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );

      expect(snapshot.lifetimeXp, 120);
      expect(snapshot.attributeXp[AttributeType.health], 100);
      expect(snapshot.attributeXp[AttributeType.discipline], 20);
    });

    test('completedQuests counts distinct completion events only', () async {
      ledger.byKey['a'] = _questTx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 0,
        createdAt: DateTime.utc(2026, 1, 10),
      );
      ledger.byKey['b'] = _questTx(
        questId: 'q1',
        dateKey: '2026-01-10',
        repeatIndex: 1,
        createdAt: DateTime.utc(2026, 1, 10),
      );
      ledger.byKey['c'] = _achievementRewardTx(
        achievementId: 'first_step',
        createdAt: DateTime.utc(2026, 1, 10),
      );

      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );
      // Two distinct quest completion events; the achievement reward
      // transaction must never count as a third.
      expect(snapshot.completedQuests, 2);
    });

    test('completedChains counts only chains with completedAt set', () async {
      await chainProgressRepository.upsert(
        ChainProgress(
          chainId: 'chain1',
          completedStageCount: 2,
          completedAt: DateTime.utc(2026, 1, 5),
        ),
      );

      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );
      expect(snapshot.completedChains, 1);
    });

    test('unlockedAchievements counts unlocks matching the catalog', () async {
      await unlockRepository.appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 5),
        ),
      ]);

      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );
      expect(snapshot.unlockedAchievements, 1);
    });

    test('firstQuestDate/latestActivityDate reflect ledger history', () async {
      ledger.byKey['a'] = _questTx(
        questId: 'q1',
        dateKey: '2026-01-05',
        createdAt: DateTime.utc(2026, 1, 5),
      );
      ledger.byKey['b'] = _questTx(
        questId: 'q2',
        dateKey: '2026-01-08',
        createdAt: DateTime.utc(2026, 1, 8),
      );

      final snapshot = await service.buildSnapshot(
        at: DateTime.utc(2026, 1, 10),
      );
      expect(snapshot.firstQuestDate, DateTime.utc(2026, 1, 5));
      expect(snapshot.latestActivityDate, DateTime.utc(2026, 1, 8));
    });

    test(
      'currentStreakDays counts consecutive completion days ending today',
      () async {
        ledger.byKey['a'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-08',
          createdAt: DateTime.utc(2026, 1, 8),
        );
        ledger.byKey['b'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-09',
          repeatIndex: 1,
          createdAt: DateTime.utc(2026, 1, 9),
        );
        ledger.byKey['c'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-10',
          repeatIndex: 2,
          createdAt: DateTime.utc(2026, 1, 10),
        );

        final snapshot = await service.buildSnapshot(
          at: DateTime.utc(2026, 1, 10),
        );
        expect(snapshot.currentStreakDays, 3);
      },
    );

    test(
      'currentStreakDays is 0 once a full day passes with no completion',
      () async {
        ledger.byKey['a'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-05',
          createdAt: DateTime.utc(2026, 1, 5),
        );

        final snapshot = await service.buildSnapshot(
          at: DateTime.utc(2026, 1, 10),
        );
        expect(snapshot.currentStreakDays, 0);
      },
    );
  });

  group('recentMilestones — ordering', () {
    test('level, achievement, and chain milestones are newest-first', () async {
      // Enough XP in one transaction to cross from level 1 straight to
      // level 2 (xpToNext(1, base: 100) = 100).
      ledger.byKey['a'] = _questTx(
        questId: 'q1',
        dateKey: '2026-01-05',
        finalXp: 100,
        createdAt: DateTime.utc(2026, 1, 5),
      );
      await unlockRepository.appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 8),
        ),
      ]);
      await chainProgressRepository.upsert(
        ChainProgress(
          chainId: 'chain1',
          completedStageCount: 2,
          completedAt: DateTime.utc(2026, 1, 12),
        ),
      );

      final milestones = await service.recentMilestones();

      expect(milestones.length, 3);
      expect(milestones[0].type, IdentityMilestoneType.chainCompleted);
      expect(milestones[0].title, 'Completed "Morning Routine"');
      expect(milestones[1].type, IdentityMilestoneType.achievementUnlocked);
      expect(milestones[1].title, 'Unlocked "First Step"');
      expect(milestones[2].type, IdentityMilestoneType.levelReached);
      expect(milestones[2].title, 'Reached Level 2');
    });

    test('respects the limit parameter', () async {
      await unlockRepository.appendAll([
        AchievementUnlock(
          achievementId: 'first_step',
          unlockedAt: DateTime.utc(2026, 1, 8),
        ),
      ]);
      await chainProgressRepository.upsert(
        ChainProgress(
          chainId: 'chain1',
          completedStageCount: 2,
          completedAt: DateTime.utc(2026, 1, 12),
        ),
      );

      final milestones = await service.recentMilestones(limit: 1);
      expect(milestones.length, 1);
      expect(milestones.single.type, IdentityMilestoneType.chainCompleted);
    });

    test(
      'a single large completion emits one level milestone per level crossed',
      () async {
        // xpToNext(1, base:100) = 100, xpToNext(2, base:100) ~= 282 -> 500 XP
        // in one transaction crosses level 1 -> 2 -> 3 in a single step.
        ledger.byKey['a'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-05',
          finalXp: 500,
          createdAt: DateTime.utc(2026, 1, 5),
        );

        final milestones = await service.recentMilestones();
        final levelTitles = milestones
            .where((m) => m.type == IdentityMilestoneType.levelReached)
            .map((m) => m.title)
            .toSet();
        expect(levelTitles, {'Reached Level 2', 'Reached Level 3'});
      },
    );

    test(
      'level milestones from separate completions sort newest-first',
      () async {
        // First tx (100 XP) crosses level 1 -> 2; second tx (300 more XP,
        // cumulative 400) crosses level 2 -> 3 — on a later day, so ordering
        // is decided by real timestamps rather than sort-stability.
        ledger.byKey['a'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-05',
          finalXp: 100,
          createdAt: DateTime.utc(2026, 1, 5),
        );
        ledger.byKey['b'] = _questTx(
          questId: 'q1',
          dateKey: '2026-01-06',
          repeatIndex: 1,
          finalXp: 300,
          createdAt: DateTime.utc(2026, 1, 6),
        );

        final milestones = await service.recentMilestones();
        final levelTitles = milestones
            .where((m) => m.type == IdentityMilestoneType.levelReached)
            .map((m) => m.title)
            .toList();
        expect(levelTitles, ['Reached Level 3', 'Reached Level 2']);
      },
    );

    test('achievements/chains outside the catalog are ignored', () async {
      await unlockRepository.appendAll([
        AchievementUnlock(
          achievementId: 'not_in_catalog',
          unlockedAt: DateTime.utc(2026, 1, 8),
        ),
      ]);
      await chainProgressRepository.upsert(
        ChainProgress(
          chainId: 'not_in_catalog',
          completedStageCount: 1,
          completedAt: DateTime.utc(2026, 1, 12),
        ),
      );

      expect(await service.recentMilestones(), isEmpty);
    });
  });
}
