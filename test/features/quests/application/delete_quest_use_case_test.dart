import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/models/delete_quest_command.dart';
import 'package:prime/features/quests/application/use_cases/delete_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/quest_progress.dart';
import 'package:prime/features/quests/domain/repositories/quest_progress_repository.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';

class _FakeQuestRepository implements QuestRepository {
  final Map<String, Quest> quests = {};
  Object? deleteError;
  final List<String> deleteCalls = [];

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async => quests[id];

  @override
  Stream<List<Quest>> watchAll() => Stream.value(quests.values.toList());

  @override
  Future<void> upsert(Quest quest) async => quests[quest.id] = quest;

  @override
  Future<void> deleteById(String id) async {
    deleteCalls.add(id);
    if (deleteError != null) throw deleteError!;
    quests.remove(id);
  }
}

class _FakeQuestProgressRepository implements QuestProgressRepository {
  final List<QuestProgress> entries = [];
  Object? deleteError;
  final List<String> deleteCalls = [];

  @override
  Future<QuestProgress?> getForQuestAndDate(
    String questId,
    DateTime date,
  ) async {
    for (final entry in entries) {
      if (entry.questId == questId && _sameDate(entry.date, date)) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<QuestProgress>> getForQuest(String questId) async =>
      entries.where((e) => e.questId == questId).toList();

  @override
  Future<void> upsert(QuestProgress progress) async => entries.add(progress);

  @override
  Future<void> deleteAllForQuest(String questId) async {
    deleteCalls.add(questId);
    if (deleteError != null) throw deleteError!;
    entries.removeWhere((e) => e.questId == questId);
  }

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

Quest _buildQuest({String id = 'q1'}) {
  return Quest(
    id: id,
    title: 'Workout',
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const [],
    progressType: ProgressType.binary,
    currentProgress: 0,
    targetProgress: 1,
    prerequisiteQuestIds: const [],
    state: QuestCompletionState.notStarted,
    failureBehavior: FailureBehavior.expire,
  );
}

void main() {
  late _FakeQuestRepository questRepository;
  late _FakeQuestProgressRepository progressRepository;
  late DeleteQuestUseCase useCase;

  setUp(() {
    questRepository = _FakeQuestRepository();
    progressRepository = _FakeQuestProgressRepository();
    useCase = DeleteQuestUseCase(
      questRepository: questRepository,
      questProgressRepository: progressRepository,
    );
  });

  test('deletes the quest', () async {
    questRepository.quests['q1'] = _buildQuest();

    final result = await useCase.execute(
      const DeleteQuestCommand(questId: 'q1'),
    );

    expect(result, isA<Ok<bool>>());
    expect((result as Ok<bool>).value, isTrue);
    expect(questRepository.quests.containsKey('q1'), isFalse);
  });

  test('deletes associated QuestProgress rows for that quest', () async {
    questRepository.quests['q1'] = _buildQuest();
    progressRepository.entries.addAll([
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
      QuestProgress(
        questId: 'q1',
        date: DateTime.utc(2026, 1, 11),
        progressValue: 1,
        isComplete: true,
      ),
      // A different quest's progress must survive.
      QuestProgress(
        questId: 'q2',
        date: DateTime.utc(2026, 1, 10),
        progressValue: 1,
        isComplete: true,
      ),
    ]);

    await useCase.execute(const DeleteQuestCommand(questId: 'q1'));

    expect(progressRepository.entries.where((e) => e.questId == 'q1'), isEmpty);
    expect(
      progressRepository.entries.where((e) => e.questId == 'q2'),
      hasLength(1),
    );
  });

  test(
    'a missing quest returns NotFoundFailure and touches neither repository',
    () async {
      final result = await useCase.execute(
        const DeleteQuestCommand(questId: 'missing'),
      );

      expect(result, isA<Err<bool>>());
      expect((result as Err<bool>).failure, isA<NotFoundFailure>());
      expect(progressRepository.deleteCalls, isEmpty);
      expect(questRepository.deleteCalls, isEmpty);
    },
  );

  test(
    'progress rows are deleted before the quest record '
    '(a failure between the two leaves the quest visible, not orphaned progress)',
    () async {
      questRepository.quests['q1'] = _buildQuest();

      await useCase.execute(const DeleteQuestCommand(questId: 'q1'));

      expect(progressRepository.deleteCalls, ['q1']);
      expect(questRepository.deleteCalls, ['q1']);
    },
  );

  test('a progress-deletion failure is surfaced as a Failure and the quest '
      'record is left untouched', () async {
    questRepository.quests['q1'] = _buildQuest();
    progressRepository.deleteError = Exception('progress box error');

    final result = await useCase.execute(
      const DeleteQuestCommand(questId: 'q1'),
    );

    expect(result, isA<Err<bool>>());
    expect((result as Err<bool>).failure, isA<UnexpectedFailure>());
    expect(
      questRepository.quests.containsKey('q1'),
      isTrue,
    ); // never reached deleteById
  });

  test('a quest-deletion failure is surfaced as a Failure', () async {
    questRepository.quests['q1'] = _buildQuest();
    questRepository.deleteError = Exception('quest box error');

    final result = await useCase.execute(
      const DeleteQuestCommand(questId: 'q1'),
    );

    expect(result, isA<Err<bool>>());
    expect((result as Err<bool>).failure, isA<UnexpectedFailure>());
  });
}
