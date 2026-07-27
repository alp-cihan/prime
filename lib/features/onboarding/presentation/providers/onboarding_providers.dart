import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/persistence_providers.dart';
import '../../../quests/presentation/providers/quest_repository_providers.dart';
import '../../application/use_cases/create_starter_quests_use_case.dart';
import '../../data/repositories/hive_onboarding_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';

part 'onboarding_providers.g.dart';

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) {
  return HiveOnboardingRepository(ref.watch(appPreferencesHiveBoxProvider));
}

@Riverpod(keepAlive: true)
CreateStarterQuestsUseCase createStarterQuestsUseCase(Ref ref) {
  return CreateStarterQuestsUseCase(
    questRepository: ref.watch(questRepositoryProvider),
    createQuestUseCase: ref.watch(createQuestUseCaseProvider),
  );
}
