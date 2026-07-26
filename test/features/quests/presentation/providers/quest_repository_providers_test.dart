import 'package:flutter_test/flutter_test.dart';
import 'package:prime/features/quests/application/use_cases/complete_quest_use_case.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_progress_repository.dart';
import 'package:prime/features/quests/data/repositories/hive_quest_repository.dart';
import 'package:prime/features/quests/presentation/providers/quest_repository_providers.dart';

import '../../../../support/hive_test_support.dart';
import '../../../../support/provider_test_support.dart';

void main() {
  late HiveTestSupport support;

  setUp(() {
    support = HiveTestSupport.start();
  });

  tearDown(() async {
    await support.dispose();
  });

  test('questRepositoryProvider returns a HiveQuestRepository', () async {
    final container = await buildTestContainer();
    addTearDown(container.dispose);

    expect(container.read(questRepositoryProvider), isA<HiveQuestRepository>());
  });

  test(
    'questProgressRepositoryProvider returns a HiveQuestProgressRepository',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      expect(
        container.read(questProgressRepositoryProvider),
        isA<HiveQuestProgressRepository>(),
      );
    },
  );

  test(
    'repository providers preserve singleton identity within one container',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      expect(
        identical(
          container.read(questRepositoryProvider),
          container.read(questRepositoryProvider),
        ),
        isTrue,
      );
      expect(
        identical(
          container.read(questProgressRepositoryProvider),
          container.read(questProgressRepositoryProvider),
        ),
        isTrue,
      );
    },
  );

  test(
    'completeQuestUseCaseProvider composes a real CompleteQuestUseCase and is a singleton',
    () async {
      final container = await buildTestContainer();
      addTearDown(container.dispose);

      final useCase = container.read(completeQuestUseCaseProvider);
      expect(useCase, isA<CompleteQuestUseCase>());
      expect(
        identical(useCase, container.read(completeQuestUseCaseProvider)),
        isTrue,
      );
    },
  );
}
