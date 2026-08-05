// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_creation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives "Add Quest" for one suggestion through
/// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
/// each card on the Suggestions page has its own independent loading state
/// (adding one suggestion never disables the "Add" button on another).
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et
/// al.: an autoDispose default would let Riverpod tear this down mid-`await`
/// the moment the card unmounts (e.g. the ranked list re-sorts and the card
/// scrolls out of the viewport), silently losing an in-flight creation's
/// outcome — the exact "at most one quest" duplicate-prevention guard
/// (`state.isLoading` below) that this controller exists to provide.

@ProviderFor(SuggestionCreationController)
final suggestionCreationControllerProvider =
    SuggestionCreationControllerFamily._();

/// Drives "Add Quest" for one suggestion through
/// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
/// each card on the Suggestions page has its own independent loading state
/// (adding one suggestion never disables the "Add" button on another).
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et
/// al.: an autoDispose default would let Riverpod tear this down mid-`await`
/// the moment the card unmounts (e.g. the ranked list re-sorts and the card
/// scrolls out of the viewport), silently losing an in-flight creation's
/// outcome — the exact "at most one quest" duplicate-prevention guard
/// (`state.isLoading` below) that this controller exists to provide.
final class SuggestionCreationControllerProvider
    extends
        $AsyncNotifierProvider<
          SuggestionCreationController,
          CreateQuestFromSuggestionOutcome?
        > {
  /// Drives "Add Quest" for one suggestion through
  /// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
  /// each card on the Suggestions page has its own independent loading state
  /// (adding one suggestion never disables the "Add" button on another).
  ///
  /// `keepAlive: true` for the same reason as `CompleteQuestController` et
  /// al.: an autoDispose default would let Riverpod tear this down mid-`await`
  /// the moment the card unmounts (e.g. the ranked list re-sorts and the card
  /// scrolls out of the viewport), silently losing an in-flight creation's
  /// outcome — the exact "at most one quest" duplicate-prevention guard
  /// (`state.isLoading` below) that this controller exists to provide.
  SuggestionCreationControllerProvider._({
    required SuggestionCreationControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'suggestionCreationControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$suggestionCreationControllerHash();

  @override
  String toString() {
    return r'suggestionCreationControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SuggestionCreationController create() => SuggestionCreationController();

  @override
  bool operator ==(Object other) {
    return other is SuggestionCreationControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$suggestionCreationControllerHash() =>
    r'63c32bdc0f72c0fff88c3a431c336fd1ec9b7424';

/// Drives "Add Quest" for one suggestion through
/// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
/// each card on the Suggestions page has its own independent loading state
/// (adding one suggestion never disables the "Add" button on another).
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et
/// al.: an autoDispose default would let Riverpod tear this down mid-`await`
/// the moment the card unmounts (e.g. the ranked list re-sorts and the card
/// scrolls out of the viewport), silently losing an in-flight creation's
/// outcome — the exact "at most one quest" duplicate-prevention guard
/// (`state.isLoading` below) that this controller exists to provide.

final class SuggestionCreationControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SuggestionCreationController,
          AsyncValue<CreateQuestFromSuggestionOutcome?>,
          CreateQuestFromSuggestionOutcome?,
          FutureOr<CreateQuestFromSuggestionOutcome?>,
          String
        > {
  SuggestionCreationControllerFamily._()
    : super(
        retry: null,
        name: r'suggestionCreationControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Drives "Add Quest" for one suggestion through
  /// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
  /// each card on the Suggestions page has its own independent loading state
  /// (adding one suggestion never disables the "Add" button on another).
  ///
  /// `keepAlive: true` for the same reason as `CompleteQuestController` et
  /// al.: an autoDispose default would let Riverpod tear this down mid-`await`
  /// the moment the card unmounts (e.g. the ranked list re-sorts and the card
  /// scrolls out of the viewport), silently losing an in-flight creation's
  /// outcome — the exact "at most one quest" duplicate-prevention guard
  /// (`state.isLoading` below) that this controller exists to provide.

  SuggestionCreationControllerProvider call(String suggestionId) =>
      SuggestionCreationControllerProvider._(
        argument: suggestionId,
        from: this,
      );

  @override
  String toString() => r'suggestionCreationControllerProvider';
}

/// Drives "Add Quest" for one suggestion through
/// [CreateQuestFromSuggestionUseCase] — a `family` keyed by suggestion id so
/// each card on the Suggestions page has its own independent loading state
/// (adding one suggestion never disables the "Add" button on another).
///
/// `keepAlive: true` for the same reason as `CompleteQuestController` et
/// al.: an autoDispose default would let Riverpod tear this down mid-`await`
/// the moment the card unmounts (e.g. the ranked list re-sorts and the card
/// scrolls out of the viewport), silently losing an in-flight creation's
/// outcome — the exact "at most one quest" duplicate-prevention guard
/// (`state.isLoading` below) that this controller exists to provide.

abstract class _$SuggestionCreationController
    extends $AsyncNotifier<CreateQuestFromSuggestionOutcome?> {
  late final _$args = ref.$arg as String;
  String get suggestionId => _$args;

  FutureOr<CreateQuestFromSuggestionOutcome?> build(String suggestionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CreateQuestFromSuggestionOutcome?>,
              CreateQuestFromSuggestionOutcome?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CreateQuestFromSuggestionOutcome?>,
                CreateQuestFromSuggestionOutcome?
              >,
              AsyncValue<CreateQuestFromSuggestionOutcome?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
