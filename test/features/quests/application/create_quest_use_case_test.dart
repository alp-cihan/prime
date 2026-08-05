import 'package:flutter_test/flutter_test.dart';
import 'package:prime/core/domain/attribute_type.dart';
import 'package:prime/core/domain/failure.dart';
import 'package:prime/core/domain/result.dart';
import 'package:prime/features/quests/application/id_generator.dart';
import 'package:prime/features/quests/application/models/create_quest_command.dart';
import 'package:prime/features/quests/application/use_cases/create_quest_use_case.dart';
import 'package:prime/features/quests/domain/entities/quest.dart';
import 'package:prime/features/quests/domain/entities/repeatability.dart';
import 'package:prime/features/quests/domain/repositories/quest_repository.dart';

class _FakeIdGenerator implements IdGenerator {
  _FakeIdGenerator(this._id);
  final String _id;

  @override
  String generate() => _id;
}

class _FakeQuestRepository implements QuestRepository {
  final Map<String, Quest> quests = {};
  Object? upsertError;

  @override
  Future<List<Quest>> getAll() async => quests.values.toList();

  @override
  Future<Quest?> getById(String id) async => quests[id];

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

CreateQuestCommand _validCommand({
  String title = 'Workout',
  String description = 'Go to the gym',
  Map<AttributeType, int> attributeXpWeights = const {AttributeType.health: 60},
  ProgressType progressType = ProgressType.binary,
  double targetProgress = 1,
  Repeatability repeatability = Repeatability.none,
  String? visualKey,
}) {
  return CreateQuestCommand(
    title: title,
    description: description,
    type: QuestType.daily,
    difficulty: QuestDifficulty.normal,
    attributeXpWeights: attributeXpWeights,
    progressType: progressType,
    targetProgress: targetProgress,
    repeatability: repeatability,
    visualKey: visualKey,
  );
}

void main() {
  late _FakeQuestRepository repository;
  late CreateQuestUseCase useCase;

  setUp(() {
    repository = _FakeQuestRepository();
    useCase = CreateQuestUseCase(
      questRepository: repository,
      idGenerator: _FakeIdGenerator('q-fixed-1'),
    );
  });

  test('creates a valid quest with sensible defaults', () async {
    final result = await useCase.execute(_validCommand());

    expect(result, isA<Ok<Quest>>());
    final quest = (result as Ok<Quest>).value;
    expect(quest.id, 'q-fixed-1');
    expect(quest.title, 'Workout');
    expect(quest.state, QuestCompletionState.notStarted);
    expect(quest.currentProgress, 0);
    expect(quest.failureBehavior, FailureBehavior.expire);
    expect(quest.linkedIdentityStatementIds, isEmpty);
    expect(quest.prerequisiteQuestIds, isEmpty);
    expect(quest.optionalReward, isNull);
    expect(quest.questChainId, isNull);
    expect(quest.visualKey, isNull); // a hand-typed quest has no visualKey
  });

  test(
    'Phase 17.2: carries a visualKey through when the command has one',
    () async {
      final result = await useCase.execute(
        _validCommand(visualKey: 'fitness/walk_20'),
      );

      final quest = (result as Ok<Quest>).value;
      expect(quest.visualKey, 'fitness/walk_20');
    },
  );

  test('trims title and description', () async {
    final result = await useCase.execute(
      _validCommand(title: '  Workout  ', description: '  desc  '),
    );

    final quest = (result as Ok<Quest>).value;
    expect(quest.title, 'Workout');
    expect(quest.description, 'desc');
  });

  test('rejects an empty title', () async {
    final result = await useCase.execute(_validCommand(title: '   '));

    expect(result, isA<Err<Quest>>());
    expect((result as Err<Quest>).failure, isA<ValidationFailure>());
  });

  test('rejects a negative attribute weight', () async {
    final result = await useCase.execute(
      _validCommand(attributeXpWeights: const {AttributeType.health: -5}),
    );

    expect(result, isA<Err<Quest>>());
  });

  test('rejects an all-zero attribute allocation', () async {
    final result = await useCase.execute(
      _validCommand(attributeXpWeights: const {AttributeType.health: 0}),
    );

    expect(result, isA<Err<Quest>>());
  });

  test('rejects an invalid target progress for a binary quest', () async {
    final result = await useCase.execute(
      _validCommand(progressType: ProgressType.binary, targetProgress: 2),
    );

    expect(result, isA<Err<Quest>>());
  });

  test('rejects an invalid target progress for a quantity quest', () async {
    final result = await useCase.execute(
      _validCommand(progressType: ProgressType.quantity, targetProgress: 0),
    );

    expect(result, isA<Err<Quest>>());
  });

  test('validates attribute allocation is non-empty', () async {
    final result = await useCase.execute(
      _validCommand(attributeXpWeights: const {}),
    );

    expect(result, isA<Err<Quest>>());
  });

  test(
    'generates the id from the injected IdGenerator deterministically',
    () async {
      final result = await useCase.execute(_validCommand());
      expect((result as Ok<Quest>).value.id, 'q-fixed-1');
    },
  );

  test('persists exactly once', () async {
    await useCase.execute(_validCommand());
    expect(repository.quests.length, 1);
  });

  test(
    'repository failure returns a Failure, not a thrown exception',
    () async {
      repository.upsertError = Exception('disk full');

      final result = await useCase.execute(_validCommand());

      expect(result, isA<Err<Quest>>());
      expect((result as Err<Quest>).failure, isA<UnexpectedFailure>());
      expect(repository.quests, isEmpty);
    },
  );
}
