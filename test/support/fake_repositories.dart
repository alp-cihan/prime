import 'dart:async';

import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/features/achievements/domain/catalog/achievement_catalog.dart';
import 'package:prime/features/achievements/domain/entities/achievement_unlock.dart';
import 'package:prime/features/achievements/domain/repositories/achievement_unlock_repository.dart';
import 'package:prime/features/chains/domain/entities/chain_progress.dart';
import 'package:prime/features/chains/domain/repositories/chain_progress_repository.dart';
import 'package:prime/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:prime/features/quests/application/clock.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/domain/repositories/quest_progress_repository.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';
import 'package:prime/features/xp_ledger/domain/entities/xp_transaction.dart';
import 'package:prime/features/xp_ledger/domain/repositories/xp_ledger_repository.dart';

/// Shared in-memory fakes for widget tests — no Hive, no temp directories.
/// Fast and sufficient since Phase 5's widgets only need real domain
/// entities flowing through real repository *interfaces*; Hive-backed
/// correctness is already covered by Phase 3/4's repository/provider tests.

class FakeQuestRepository implements QuestRepository {
  final Map<String, Quest> quests = {};
  final _controller = _BroadcastList<Quest>();

  /// When set, [getById] suspends on this before returning — lets a test
  /// pause mid-completion (CompleteQuestUseCase's first repository call) to
  /// deterministically observe a loading UI state, rather than racing a
  /// fake that would otherwise resolve within the same microtask flush.
  Completer<void>? getByIdGate;

  /// Same idea as [getByIdGate], for Phase 7's create/update flows —
  /// deterministically observes the form controller's loading state instead
  /// of racing a fake that would otherwise resolve within one microtask.
  Completer<void>? upsertGate;

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async {
    final gate = getByIdGate;
    if (gate != null) await gate.future;
    return quests[id];
  }

  @override
  Stream<List<Quest>> watchAll() =>
      _controller.stream(() => quests.values.toList());

  @override
  Future<void> upsert(Quest quest) async {
    final gate = upsertGate;
    if (gate != null) await gate.future;
    quests[quest.id] = quest;
    _controller.notify(quests.values.toList());
  }

  @override
  Future<void> deleteById(String id) async {
    quests.remove(id);
    _controller.notify(quests.values.toList());
  }
}

class FakeQuestProgressRepository implements QuestProgressRepository {
  final List<QuestProgress> entries = [];

  /// When set, [deleteAllForQuest] suspends on this before returning — lets
  /// a test deterministically observe `DeleteQuestController`'s loading
  /// state (it is the first repository call `DeleteQuestUseCase` makes
  /// after loading the quest).
  Completer<void>? deleteAllForQuestGate;

  /// When set, [deleteAllForQuest] throws this instead of succeeding — lets
  /// a test exercise `DeleteQuestController`'s error path deterministically.
  Object? deleteAllForQuestError;

  /// When set, [upsert] suspends on this before returning — lets a test
  /// deterministically observe `QuestProgressController`'s loading state
  /// for a non-completing increment/decrement (the use case's only
  /// repository write on that path).
  Completer<void>? upsertGate;

  @override
  Future<QuestProgress?> getForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    for (final entry in entries) {
      if (entry.questId == questId && _sameDate(entry.date, date)) return entry;
    }
    return null;
  }

  @override
  Future<List<QuestProgress>> getForQuest(String questId) async =>
      entries.where((e) => e.questId == questId).toList();

  @override
  Future<void> upsert(QuestProgress progress) async {
    final gate = upsertGate;
    if (gate != null) await gate.future;
    entries.removeWhere(
      (e) => e.questId == progress.questId && _sameDate(e.date, progress.date),
    );
    entries.add(progress);
  }

  @override
  Future<void> deleteAllForQuest(String questId) async {
    final gate = deleteAllForQuestGate;
    if (gate != null) await gate.future;
    if (deleteAllForQuestError != null) throw deleteAllForQuestError!;
    entries.removeWhere((e) => e.questId == questId);
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class FakeXpLedgerRepository implements XpLedgerRepository {
  final Map<String, XpTransaction> byKey = {};

  @override
  Future<void> appendAll(List<XpTransaction> transactions) async {
    for (final t in transactions) {
      byKey.putIfAbsent(t.idempotencyKey, () => t);
    }
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    final prefix = '$questId|${_dateKey(date)}|';
    return byKey.values.where((t) => t.sourceId.startsWith(prefix)).toList();
  }

  @override
  Future<List<XpTransaction>> getTransactionsForQuest(String questId) async {
    final prefix = '$questId|';
    return byKey.values.where((t) => t.sourceId.startsWith(prefix)).toList();
  }

  @override
  Future<List<XpTransaction>> getTransactionsForDate(DateTime date) async {
    final dateKey = _dateKey(date);
    return byKey.values
        .where(
          (t) =>
              t.sourceId.split('|').length >= 2 &&
              t.sourceId.split('|')[1] == dateKey,
        )
        .toList();
  }

  @override
  Future<List<XpTransaction>> getAll() async => byKey.values.toList();

  @override
  Future<int> sumLifetimeXp() async =>
      byKey.values.fold<int>(0, (sum, t) => sum + t.finalXp);

  @override
  Future<int> sumXpForAttribute(AttributeType type) async => byKey.values
      .where((t) => t.attribute == type)
      .fold<int>(0, (sum, t) => sum + t.finalXp);

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class FakeAchievementUnlockRepository implements AchievementUnlockRepository {
  FakeAchievementUnlockRepository();

  /// Pre-seeded with every built-in catalog achievement already "unlocked"
  /// — for widget tests about other features (quest CRUD, completion,
  /// level-up) that would otherwise incidentally also become achievement
  /// tests: with every achievement already unlocked, evaluation always
  /// finds nothing new eligible, so no reward XP is granted and no unlock
  /// dialog ever appears to interfere with that test's own navigation/XP
  /// assertions. The achievements feature's own behavior is covered by its
  /// dedicated test suite instead.
  factory FakeAchievementUnlockRepository.allUnlocked() {
    final repository = FakeAchievementUnlockRepository();
    final placeholderUnlockedAt = DateTime.utc(2000, 1, 1);
    for (final achievement in achievementCatalog) {
      repository.unlocks[achievement.id] = AchievementUnlock(
        achievementId: achievement.id,
        unlockedAt: placeholderUnlockedAt,
      );
    }
    return repository;
  }

  final Map<String, AchievementUnlock> unlocks = {};
  final _controller = _BroadcastList<AchievementUnlock>();

  @override
  Future<List<AchievementUnlock>> getAll() async => unlocks.values.toList();

  @override
  Future<bool> isUnlocked(String achievementId) async =>
      unlocks.containsKey(achievementId);

  @override
  Stream<List<AchievementUnlock>> watchAll() =>
      _controller.stream(() => unlocks.values.toList());

  @override
  Future<void> appendAll(List<AchievementUnlock> newUnlocks) async {
    var changed = false;
    for (final unlock in newUnlocks) {
      if (unlocks.containsKey(unlock.achievementId)) continue;
      unlocks[unlock.achievementId] = unlock;
      changed = true;
    }
    if (changed) _controller.notify(unlocks.values.toList());
  }
}

class FakeChainProgressRepository implements ChainProgressRepository {
  final Map<String, ChainProgress> progress = {};
  final _controller = _BroadcastList<ChainProgress>();

  @override
  Future<ChainProgress?> getForChain(String chainId) async => progress[chainId];

  @override
  Future<List<ChainProgress>> getAll() async => progress.values.toList();

  @override
  Stream<List<ChainProgress>> watchAll() =>
      _controller.stream(() => progress.values.toList());

  @override
  Future<void> upsert(ChainProgress value) async {
    progress[value.chainId] = value;
    _controller.notify(progress.values.toList());
  }
}

/// [completed] defaults to `true` — most widget tests are about some other
/// feature and need to land straight on real app content, not the
/// onboarding gate; dedicated onboarding tests pass `completed: false`.
class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({bool completed = true}) : _completed = completed;

  bool _completed;

  @override
  bool isCompleted() => _completed;

  @override
  void markCompleted() => _completed = true;

  @override
  void reset() => _completed = false;
}

class FakeClock implements Clock {
  FakeClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Mutates "now" in place — the same [FakeClock] instance stays installed
  /// via `clockProvider.overrideWithValue`, so callers must still invalidate
  /// whatever downstream provider they want to see recompute (e.g.
  /// `todayUtcProvider`/`questOccurrenceAnchorDateProvider`); overriding a
  /// provider with a fixed value means Riverpod never notices the object's
  /// internal state changed on its own.
  void advanceTo(DateTime next) => _now = next;
}

/// Minimal broadcast helper backing `FakeQuestRepository.watchAll` — mirrors
/// `HiveQuestRepository.watchAll`'s contract (emit current snapshot
/// immediately, then again on every change) without needing a real Hive box.
class _BroadcastList<T> {
  final List<void Function(List<T>)> _listeners = [];

  Stream<List<T>> stream(List<T> Function() current) {
    late final StreamController<List<T>> controller;
    void listener(List<T> value) => controller.add(value);
    controller = StreamController<List<T>>(
      onListen: () {
        _listeners.add(listener);
        controller.add(current());
      },
      onCancel: () => _listeners.remove(listener),
    );
    return controller.stream;
  }

  void notify(List<T> value) {
    for (final listener in List.of(_listeners)) {
      listener(value);
    }
  }
}
