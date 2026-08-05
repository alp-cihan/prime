// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranked_suggestions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Suggestions page's ranked list — recomputes automatically whenever
/// any input changes: the live quest list (so a newly created/deleted quest
/// immediately affects duplicate exclusion, the same "existing streams"
/// mechanism the phase brief asks for), the recommendation profile
/// (editor saves, or a suggestion being marked accepted), or the session
/// goal filter.

@ProviderFor(rankedSuggestions)
final rankedSuggestionsProvider = RankedSuggestionsProvider._();

/// The Suggestions page's ranked list — recomputes automatically whenever
/// any input changes: the live quest list (so a newly created/deleted quest
/// immediately affects duplicate exclusion, the same "existing streams"
/// mechanism the phase brief asks for), the recommendation profile
/// (editor saves, or a suggestion being marked accepted), or the session
/// goal filter.

final class RankedSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestSuggestion>>,
          List<QuestSuggestion>,
          FutureOr<List<QuestSuggestion>>
        >
    with
        $FutureModifier<List<QuestSuggestion>>,
        $FutureProvider<List<QuestSuggestion>> {
  /// The Suggestions page's ranked list — recomputes automatically whenever
  /// any input changes: the live quest list (so a newly created/deleted quest
  /// immediately affects duplicate exclusion, the same "existing streams"
  /// mechanism the phase brief asks for), the recommendation profile
  /// (editor saves, or a suggestion being marked accepted), or the session
  /// goal filter.
  RankedSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rankedSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rankedSuggestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestSuggestion>> create(Ref ref) {
    return rankedSuggestions(ref);
  }
}

String _$rankedSuggestionsHash() => r'ed2953f94f24312a944521ba17641e59625a30be';
