// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_filter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Session-only goal-area filter chips on the Suggestions page — never
/// persisted (Phase 16: "Do not persist ranking results"), so it resets to
/// "no filter" every time the page is freshly opened. Default `autoDispose`
/// is exactly right here: once nothing watches it (the page is left), it's
/// gone.

@ProviderFor(SuggestionFilterController)
final suggestionFilterControllerProvider =
    SuggestionFilterControllerProvider._();

/// Session-only goal-area filter chips on the Suggestions page — never
/// persisted (Phase 16: "Do not persist ranking results"), so it resets to
/// "no filter" every time the page is freshly opened. Default `autoDispose`
/// is exactly right here: once nothing watches it (the page is left), it's
/// gone.
final class SuggestionFilterControllerProvider
    extends $NotifierProvider<SuggestionFilterController, Set<GoalArea>> {
  /// Session-only goal-area filter chips on the Suggestions page — never
  /// persisted (Phase 16: "Do not persist ranking results"), so it resets to
  /// "no filter" every time the page is freshly opened. Default `autoDispose`
  /// is exactly right here: once nothing watches it (the page is left), it's
  /// gone.
  SuggestionFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestionFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestionFilterControllerHash();

  @$internal
  @override
  SuggestionFilterController create() => SuggestionFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<GoalArea> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<GoalArea>>(value),
    );
  }
}

String _$suggestionFilterControllerHash() =>
    r'8348ac5d10e78d222e5fa10b104215422cb08e92';

/// Session-only goal-area filter chips on the Suggestions page — never
/// persisted (Phase 16: "Do not persist ranking results"), so it resets to
/// "no filter" every time the page is freshly opened. Default `autoDispose`
/// is exactly right here: once nothing watches it (the page is left), it's
/// gone.

abstract class _$SuggestionFilterController extends $Notifier<Set<GoalArea>> {
  Set<GoalArea> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<GoalArea>, Set<GoalArea>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<GoalArea>, Set<GoalArea>>,
              Set<GoalArea>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
