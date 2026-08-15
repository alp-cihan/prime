// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Completed-today count and active-quest total for the Daily Progress
/// card. Watches each active quest's [questProgressForDateProvider] instance
/// directly (rather than re-deriving from a repository read of its own) so
/// that `CompleteQuestController`'s existing invalidation of that exact
/// family provider automatically recomputes this summary too — no separate
/// invalidation wiring needed for this provider.

@ProviderFor(todayQuestProgressSummary)
final todayQuestProgressSummaryProvider = TodayQuestProgressSummaryProvider._();

/// Completed-today count and active-quest total for the Daily Progress
/// card. Watches each active quest's [questProgressForDateProvider] instance
/// directly (rather than re-deriving from a repository read of its own) so
/// that `CompleteQuestController`'s existing invalidation of that exact
/// family provider automatically recomputes this summary too — no separate
/// invalidation wiring needed for this provider.

final class TodayQuestProgressSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayQuestProgressSummary>,
          TodayQuestProgressSummary,
          FutureOr<TodayQuestProgressSummary>
        >
    with
        $FutureModifier<TodayQuestProgressSummary>,
        $FutureProvider<TodayQuestProgressSummary> {
  /// Completed-today count and active-quest total for the Daily Progress
  /// card. Watches each active quest's [questProgressForDateProvider] instance
  /// directly (rather than re-deriving from a repository read of its own) so
  /// that `CompleteQuestController`'s existing invalidation of that exact
  /// family provider automatically recomputes this summary too — no separate
  /// invalidation wiring needed for this provider.
  TodayQuestProgressSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayQuestProgressSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayQuestProgressSummaryHash();

  @$internal
  @override
  $FutureProviderElement<TodayQuestProgressSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodayQuestProgressSummary> create(Ref ref) {
    return todayQuestProgressSummary(ref);
  }
}

String _$todayQuestProgressSummaryHash() =>
    r'aa38bf5cc3cd5d4ab61475ccb2b65162e5492c6d';

/// The Main Quest card's selection (docs/architecture.md §13.3): the first
/// active quest not yet completed today, in [watchAllQuestsProvider]'s own
/// deterministic order; if every active quest is already complete, falls
/// back to the first active quest; `null` only when there are no active
/// quests at all (the empty state).

@ProviderFor(featuredQuest)
final featuredQuestProvider = FeaturedQuestProvider._();

/// The Main Quest card's selection (docs/architecture.md §13.3): the first
/// active quest not yet completed today, in [watchAllQuestsProvider]'s own
/// deterministic order; if every active quest is already complete, falls
/// back to the first active quest; `null` only when there are no active
/// quests at all (the empty state).

final class FeaturedQuestProvider
    extends $FunctionalProvider<AsyncValue<Quest?>, Quest?, FutureOr<Quest?>>
    with $FutureModifier<Quest?>, $FutureProvider<Quest?> {
  /// The Main Quest card's selection (docs/architecture.md §13.3): the first
  /// active quest not yet completed today, in [watchAllQuestsProvider]'s own
  /// deterministic order; if every active quest is already complete, falls
  /// back to the first active quest; `null` only when there are no active
  /// quests at all (the empty state).
  FeaturedQuestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredQuestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredQuestHash();

  @$internal
  @override
  $FutureProviderElement<Quest?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Quest?> create(Ref ref) {
    return featuredQuest(ref);
  }
}

String _$featuredQuestHash() => r'c78470d7a0b2228a95de2c146f04c4ef98061c75';

/// Phase 18 — the Today 2.0 "Continue" section's selection: the first
/// active, non-binary quest (quantity/duration — binary quests are only ever
/// "done" or "not done," so they have no partial "progress" to continue)
/// that already has measurable progress today (`progressValue > 0`) but
/// isn't complete yet, excluding whichever quest [featuredQuest]'s same
/// selection rule already put in the hero card — Continue exists to surface
/// a *second* quest worth resuming, never to duplicate the hero. Same
/// deterministic ordering as [featuredQuest] ([watchAllQuestsProvider]'s own
/// order); `null` when nothing qualifies, which is exactly when the
/// presentation layer omits the section entirely.

@ProviderFor(continueQuest)
final continueQuestProvider = ContinueQuestProvider._();

/// Phase 18 — the Today 2.0 "Continue" section's selection: the first
/// active, non-binary quest (quantity/duration — binary quests are only ever
/// "done" or "not done," so they have no partial "progress" to continue)
/// that already has measurable progress today (`progressValue > 0`) but
/// isn't complete yet, excluding whichever quest [featuredQuest]'s same
/// selection rule already put in the hero card — Continue exists to surface
/// a *second* quest worth resuming, never to duplicate the hero. Same
/// deterministic ordering as [featuredQuest] ([watchAllQuestsProvider]'s own
/// order); `null` when nothing qualifies, which is exactly when the
/// presentation layer omits the section entirely.

final class ContinueQuestProvider
    extends $FunctionalProvider<AsyncValue<Quest?>, Quest?, FutureOr<Quest?>>
    with $FutureModifier<Quest?>, $FutureProvider<Quest?> {
  /// Phase 18 — the Today 2.0 "Continue" section's selection: the first
  /// active, non-binary quest (quantity/duration — binary quests are only ever
  /// "done" or "not done," so they have no partial "progress" to continue)
  /// that already has measurable progress today (`progressValue > 0`) but
  /// isn't complete yet, excluding whichever quest [featuredQuest]'s same
  /// selection rule already put in the hero card — Continue exists to surface
  /// a *second* quest worth resuming, never to duplicate the hero. Same
  /// deterministic ordering as [featuredQuest] ([watchAllQuestsProvider]'s own
  /// order); `null` when nothing qualifies, which is exactly when the
  /// presentation layer omits the section entirely.
  ContinueQuestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continueQuestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continueQuestHash();

  @$internal
  @override
  $FutureProviderElement<Quest?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Quest?> create(Ref ref) {
    return continueQuest(ref);
  }
}

String _$continueQuestHash() => r'1454fa1c76f76bd0f0b10deaba70b98c2e09851e';

/// Every XP transaction recorded today, across all quests — the Activity/XP
/// Summary section's source of truth.

@ProviderFor(todayXpTransactions)
final todayXpTransactionsProvider = TodayXpTransactionsProvider._();

/// Every XP transaction recorded today, across all quests — the Activity/XP
/// Summary section's source of truth.

final class TodayXpTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<XpTransaction>>,
          List<XpTransaction>,
          FutureOr<List<XpTransaction>>
        >
    with
        $FutureModifier<List<XpTransaction>>,
        $FutureProvider<List<XpTransaction>> {
  /// Every XP transaction recorded today, across all quests — the Activity/XP
  /// Summary section's source of truth.
  TodayXpTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayXpTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayXpTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<List<XpTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<XpTransaction>> create(Ref ref) {
    return todayXpTransactions(ref);
  }
}

String _$todayXpTransactionsHash() =>
    r'8c0474872f7f5dfd006deb48f070641defe3e1af';

@ProviderFor(todayXpTotal)
final todayXpTotalProvider = TodayXpTotalProvider._();

final class TodayXpTotalProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TodayXpTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayXpTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayXpTotalHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return todayXpTotal(ref);
  }
}

String _$todayXpTotalHash() => r'6ad6dccdc52c2e30c026514bc0ba6e0a026f51c9';

/// Only attributes with at least one XP transaction today are present in
/// the result — the caller is not expected to render eight zero-value rows.

@ProviderFor(todayXpByAttribute)
final todayXpByAttributeProvider = TodayXpByAttributeProvider._();

/// Only attributes with at least one XP transaction today are present in
/// the result — the caller is not expected to render eight zero-value rows.

final class TodayXpByAttributeProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<AttributeType, int>>,
          Map<AttributeType, int>,
          FutureOr<Map<AttributeType, int>>
        >
    with
        $FutureModifier<Map<AttributeType, int>>,
        $FutureProvider<Map<AttributeType, int>> {
  /// Only attributes with at least one XP transaction today are present in
  /// the result — the caller is not expected to render eight zero-value rows.
  TodayXpByAttributeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayXpByAttributeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayXpByAttributeHash();

  @$internal
  @override
  $FutureProviderElement<Map<AttributeType, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<AttributeType, int>> create(Ref ref) {
    return todayXpByAttribute(ref);
  }
}

String _$todayXpByAttributeHash() =>
    r'92951a58c3159883f00e225d508dfa20ac6aa474';
