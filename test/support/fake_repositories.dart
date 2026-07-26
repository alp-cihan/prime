import 'dart:async';

import 'package:prime/core/domain/attribute_type.dart';
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
    quests[quest.id] = quest;
    _controller.notify(quests.values.toList());
  }
}

class FakeQuestProgressRepository implements QuestProgressRepository {
  final List<QuestProgress> entries = [];

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
    entries.removeWhere(
      (e) => e.questId == progress.questId && _sameDate(e.date, progress.date),
    );
    entries.add(progress);
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

class FakeClock implements Clock {
  FakeClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
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
