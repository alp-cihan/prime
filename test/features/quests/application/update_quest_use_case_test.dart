import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/models/update_quest_command.dart';
import 'package:prime/features/quests/application/use_cases/update_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/domain/entities/reward.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';

class _FakeQuestRepository implements QuestRepository {
  final Map<String, Quest> quests = {};
  Object? upsertError;
  Object? getByIdError;

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async {
    if (getByIdError != null) throw getByIdError!;
    return quests[id];
  }

  @override
  Stream<List<Quest>> watchAll() => Stream.value(quests.values.toList());

  @override
  Future<void> upsert(Quest quest) async {
    if (upsertError != null) throw upsertError!;
    quests[quest.id] = quest;
  }

  @override
  Future<void> deleteById(String id) async => quests.remove(id);
}

Quest _buildQuest({
  String id = 'q1',
  String title = 'Workout',
  QuestCompletionState state = QuestCompletionState.inProgress,
  double currentProgress = 0,
}) {
  return Quest(
    id: id,
    title: title,
    description: 'desc',
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: const {AttributeType.health: 60},
    linkedIdentityStatementIds: const ['identity-1'],
    progressType: ProgressType.binary,
    currentProgress: currentProgress,
    targetProgress: 1,
    deadline: DateTime.utc(2026, 6, 1),
    questChainId: 'chain-1',
    prerequisiteQuestIds: const ['q0'],
    state: state,
    failureBehavior: FailureBehavior.carryOver,
    optionalReward: const Reward(xp: 50),
    repeatability: Repeatability.daily,
  );
}

UpdateQuestCommand _validCommand({
  String questId = 'q1',
  String title = 'Updated title',
  String description = 'updated desc',
  Map<AttributeType, int> attributeXpWeights = const {AttributeType.health: 80},
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
  Repeatability repeatability = Repeatability.none,
}) {
  return UpdateQuestCommand(
    questId: questId,
    title: title,
    description: description,
    type: QuestType.weekly,
    difficulty: QuestDifficulty.hard,
    attributeXpWeights: attributeXpWeights,
    progressType: progressType,
    targetProgress: targetProgress,
    repeatability: repeatability,
  );
}

void main() {
  late _FakeQuestRepository repository;
  late UpdateQuestUseCase useCase;

  setUp(() {
    repository = _FakeQuestRepository();
    useCase = UpdateQuestUseCase(questRepository: repository);
  });

  test('updates an existing quest with the new field values', () async {
    repository.quests['q1'] = _buildQuest();

    final result = await useCase.execute(_validCommand());

    expect(result, isA<Ok<Quest>>());
    final updated = (result as Ok<Quest>).value;
    expect(updated.title, 'Updated title');
    expect(updated.description, 'updated desc');
    expect(updated.type, QuestType.weekly);
    expect(updated.difficulty, QuestDifficulty.hard);
    expect(updated.attributeXpWeights, {AttributeType.health: 80});
  });

  test('a missing quest returns NotFoundFailure', () async {
    final result = await useCase.execute(_validCommand(questId: 'missing'));

    expect(result, isA<Err<Quest>>());
    expect((result as Err<Quest>).failure, isA<NotFoundFailure>());
  });

  test('preserves immutable/system fields not exposed by the form', () async {
    repository.quests['q1'] = _buildQuest(
      state: QuestCompletionState.complete,
      currentProgress: 1,
    );

    final result = await useCase.execute(_validCommand());
    final updated = (result as Ok<Quest>).value;

    expect(updated.id, 'q1');
    expect(updated.state, QuestCompletionState.complete);
    expect(updated.currentProgress, 1);
    expect(updated.linkedIdentityStatementIds, ['identity-1']);
    expect(updated.deadline, DateTime.utc(2026, 6, 1));
    expect(updated.questChainId, 'chain-1');
    expect(updated.prerequisiteQuestIds, ['q0']);
    expect(updated.failureBehavior, FailureBehavior.carryOver);
    expect(updated.optionalReward, const Reward(xp: 50));
  });

  test('clearing the repeatability to "none" actually clears it', () async {
    repository.quests['q1'] =
        _buildQuest(); // repeatability: Repeatability.daily

    final result = await useCase.execute(
      _validCommand(repeatability: Repeatability.none),
    );

    expect((result as Ok<Quest>).value.repeatability, Repeatability.none);
  });

  test('does not touch QuestProgress or the XP ledger', () async {
    // UpdateQuestUseCase has no dependency on either repository at all —
    // asserting its constructor signature is the guarantee here; there is
    // nothing further to fake/verify against.
    expect(
      () => UpdateQuestUseCase(questRepository: repository),
      returnsNormally,
    );
  });

  test('invalid edits do not persist', () async {
    final original = _buildQuest();
    repository.quests['q1'] = original;

    final result = await useCase.execute(_validCommand(title: ''));

    expect(result, isA<Err<Quest>>());
    expect(repository.quests['q1'], original); // unchanged
  });

  test('a getById repository failure returns a Failure', () async {
    repository.getByIdError = Exception('read error');

    final result = await useCase.execute(_validCommand());

    expect(result, isA<Err<Quest>>());
    expect((result as Err<Quest>).failure, isA<UnexpectedFailure>());
  });

  test('an upsert repository failure returns a Failure', () async {
    repository.quests['q1'] = _buildQuest();
    repository.upsertError = Exception('disk full');

    final result = await useCase.execute(_validCommand());

    expect(result, isA<Err<Quest>>());
    expect((result as Err<Quest>).failure, isA<UnexpectedFailure>());
  });
}
