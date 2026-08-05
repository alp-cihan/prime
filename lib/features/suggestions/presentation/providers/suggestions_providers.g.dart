// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singletons for the app's lifetime — same reasoning as every other
/// repository/use-case provider in `quest_repository_providers.dart`: each
/// wraps an already-open Hive box or holds no mutable state of its own, so
/// nothing about it needs to be recreated mid-session.

@ProviderFor(recommendationProfileRepository)
final recommendationProfileRepositoryProvider =
    RecommendationProfileRepositoryProvider._();

/// Singletons for the app's lifetime — same reasoning as every other
/// repository/use-case provider in `quest_repository_providers.dart`: each
/// wraps an already-open Hive box or holds no mutable state of its own, so
/// nothing about it needs to be recreated mid-session.

final class RecommendationProfileRepositoryProvider
    extends
        $FunctionalProvider<
          RecommendationProfileRepository,
          RecommendationProfileRepository,
          RecommendationProfileRepository
        >
    with $Provider<RecommendationProfileRepository> {
  /// Singletons for the app's lifetime — same reasoning as every other
  /// repository/use-case provider in `quest_repository_providers.dart`: each
  /// wraps an already-open Hive box or holds no mutable state of its own, so
  /// nothing about it needs to be recreated mid-session.
  RecommendationProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<RecommendationProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecommendationProfileRepository create(Ref ref) {
    return recommendationProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecommendationProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecommendationProfileRepository>(
        value,
      ),
    );
  }
}

String _$recommendationProfileRepositoryHash() =>
    r'30b1d94f05b1fa6f2d308feaa21e54287798c876';

@ProviderFor(suggestionRankingPolicy)
final suggestionRankingPolicyProvider = SuggestionRankingPolicyProvider._();

final class SuggestionRankingPolicyProvider
    extends
        $FunctionalProvider<
          SuggestionRankingPolicy,
          SuggestionRankingPolicy,
          SuggestionRankingPolicy
        >
    with $Provider<SuggestionRankingPolicy> {
  SuggestionRankingPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestionRankingPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestionRankingPolicyHash();

  @$internal
  @override
  $ProviderElement<SuggestionRankingPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SuggestionRankingPolicy create(Ref ref) {
    return suggestionRankingPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SuggestionRankingPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SuggestionRankingPolicy>(value),
    );
  }
}

String _$suggestionRankingPolicyHash() =>
    r'cb2ea03dc16ed9a5e7e602c3b080f9199da2eb88';

@ProviderFor(getRankedSuggestionsUseCase)
final getRankedSuggestionsUseCaseProvider =
    GetRankedSuggestionsUseCaseProvider._();

final class GetRankedSuggestionsUseCaseProvider
    extends
        $FunctionalProvider<
          GetRankedSuggestionsUseCase,
          GetRankedSuggestionsUseCase,
          GetRankedSuggestionsUseCase
        >
    with $Provider<GetRankedSuggestionsUseCase> {
  GetRankedSuggestionsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRankedSuggestionsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRankedSuggestionsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRankedSuggestionsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRankedSuggestionsUseCase create(Ref ref) {
    return getRankedSuggestionsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRankedSuggestionsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRankedSuggestionsUseCase>(value),
    );
  }
}

String _$getRankedSuggestionsUseCaseHash() =>
    r'14b5713b77e05ae0297000f4d038ce3ade57d7e3';

@ProviderFor(loadRecommendationProfileUseCase)
final loadRecommendationProfileUseCaseProvider =
    LoadRecommendationProfileUseCaseProvider._();

final class LoadRecommendationProfileUseCaseProvider
    extends
        $FunctionalProvider<
          LoadRecommendationProfileUseCase,
          LoadRecommendationProfileUseCase,
          LoadRecommendationProfileUseCase
        >
    with $Provider<LoadRecommendationProfileUseCase> {
  LoadRecommendationProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadRecommendationProfileUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadRecommendationProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadRecommendationProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadRecommendationProfileUseCase create(Ref ref) {
    return loadRecommendationProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadRecommendationProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadRecommendationProfileUseCase>(
        value,
      ),
    );
  }
}

String _$loadRecommendationProfileUseCaseHash() =>
    r'c295c5824f06404c34e42d81b4ef7de792e680c7';

@ProviderFor(saveRecommendationProfileUseCase)
final saveRecommendationProfileUseCaseProvider =
    SaveRecommendationProfileUseCaseProvider._();

final class SaveRecommendationProfileUseCaseProvider
    extends
        $FunctionalProvider<
          SaveRecommendationProfileUseCase,
          SaveRecommendationProfileUseCase,
          SaveRecommendationProfileUseCase
        >
    with $Provider<SaveRecommendationProfileUseCase> {
  SaveRecommendationProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveRecommendationProfileUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveRecommendationProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveRecommendationProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveRecommendationProfileUseCase create(Ref ref) {
    return saveRecommendationProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveRecommendationProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveRecommendationProfileUseCase>(
        value,
      ),
    );
  }
}

String _$saveRecommendationProfileUseCaseHash() =>
    r'b0018ea350284d49ef78b8e7f9983a4d72c9141e';

@ProviderFor(createQuestFromSuggestionUseCase)
final createQuestFromSuggestionUseCaseProvider =
    CreateQuestFromSuggestionUseCaseProvider._();

final class CreateQuestFromSuggestionUseCaseProvider
    extends
        $FunctionalProvider<
          CreateQuestFromSuggestionUseCase,
          CreateQuestFromSuggestionUseCase,
          CreateQuestFromSuggestionUseCase
        >
    with $Provider<CreateQuestFromSuggestionUseCase> {
  CreateQuestFromSuggestionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createQuestFromSuggestionUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createQuestFromSuggestionUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateQuestFromSuggestionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateQuestFromSuggestionUseCase create(Ref ref) {
    return createQuestFromSuggestionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateQuestFromSuggestionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateQuestFromSuggestionUseCase>(
        value,
      ),
    );
  }
}

String _$createQuestFromSuggestionUseCaseHash() =>
    r'056860a88b96a0a7b75b360f9766354d828d82d9';
