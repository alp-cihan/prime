// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_ledger_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singleton for the app's lifetime — wraps the already-open XP ledger box.

@ProviderFor(xpLedgerRepository)
final xpLedgerRepositoryProvider = XpLedgerRepositoryProvider._();

/// Singleton for the app's lifetime — wraps the already-open XP ledger box.

final class XpLedgerRepositoryProvider
    extends
        $FunctionalProvider<
          XpLedgerRepository,
          XpLedgerRepository,
          XpLedgerRepository
        >
    with $Provider<XpLedgerRepository> {
  /// Singleton for the app's lifetime — wraps the already-open XP ledger box.
  XpLedgerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xpLedgerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xpLedgerRepositoryHash();

  @$internal
  @override
  $ProviderElement<XpLedgerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  XpLedgerRepository create(Ref ref) {
    return xpLedgerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(XpLedgerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<XpLedgerRepository>(value),
    );
  }
}

String _$xpLedgerRepositoryHash() =>
    r'a5da96f072b9a84dccfb712297e73ec799820529';

/// Transactions for one `(questId, date)`, deterministically ordered by the
/// repository. [date] must already be UTC-date-normalized — this provider's
/// family key is the exact [date] value, so a caller passing a raw,
/// un-normalized `DateTime` would create a separate cache entry per distinct
/// time-of-day instead of sharing one per calendar day. Every consumer in
/// this codebase (queries and `CompleteQuestController`'s invalidation)
/// normalizes before calling this provider — see
/// `CompleteQuestUseCase._normalizeDate` for the same convention.

@ProviderFor(xpTransactionsForQuestAndDate)
final xpTransactionsForQuestAndDateProvider =
    XpTransactionsForQuestAndDateFamily._();

/// Transactions for one `(questId, date)`, deterministically ordered by the
/// repository. [date] must already be UTC-date-normalized — this provider's
/// family key is the exact [date] value, so a caller passing a raw,
/// un-normalized `DateTime` would create a separate cache entry per distinct
/// time-of-day instead of sharing one per calendar day. Every consumer in
/// this codebase (queries and `CompleteQuestController`'s invalidation)
/// normalizes before calling this provider — see
/// `CompleteQuestUseCase._normalizeDate` for the same convention.

final class XpTransactionsForQuestAndDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<XpTransaction>>,
          List<XpTransaction>,
          FutureOr<List<XpTransaction>>
        >
    with
        $FutureModifier<List<XpTransaction>>,
        $FutureProvider<List<XpTransaction>> {
  /// Transactions for one `(questId, date)`, deterministically ordered by the
  /// repository. [date] must already be UTC-date-normalized — this provider's
  /// family key is the exact [date] value, so a caller passing a raw,
  /// un-normalized `DateTime` would create a separate cache entry per distinct
  /// time-of-day instead of sharing one per calendar day. Every consumer in
  /// this codebase (queries and `CompleteQuestController`'s invalidation)
  /// normalizes before calling this provider — see
  /// `CompleteQuestUseCase._normalizeDate` for the same convention.
  XpTransactionsForQuestAndDateProvider._({
    required XpTransactionsForQuestAndDateFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'xpTransactionsForQuestAndDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$xpTransactionsForQuestAndDateHash();

  @override
  String toString() {
    return r'xpTransactionsForQuestAndDateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<XpTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<XpTransaction>> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return xpTransactionsForQuestAndDate(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is XpTransactionsForQuestAndDateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$xpTransactionsForQuestAndDateHash() =>
    r'f4d3ac8979cc09dcd2e6d7738c709878e5c9eb73';

/// Transactions for one `(questId, date)`, deterministically ordered by the
/// repository. [date] must already be UTC-date-normalized — this provider's
/// family key is the exact [date] value, so a caller passing a raw,
/// un-normalized `DateTime` would create a separate cache entry per distinct
/// time-of-day instead of sharing one per calendar day. Every consumer in
/// this codebase (queries and `CompleteQuestController`'s invalidation)
/// normalizes before calling this provider — see
/// `CompleteQuestUseCase._normalizeDate` for the same convention.

final class XpTransactionsForQuestAndDateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<XpTransaction>>,
          (String, DateTime)
        > {
  XpTransactionsForQuestAndDateFamily._()
    : super(
        retry: null,
        name: r'xpTransactionsForQuestAndDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Transactions for one `(questId, date)`, deterministically ordered by the
  /// repository. [date] must already be UTC-date-normalized — this provider's
  /// family key is the exact [date] value, so a caller passing a raw,
  /// un-normalized `DateTime` would create a separate cache entry per distinct
  /// time-of-day instead of sharing one per calendar day. Every consumer in
  /// this codebase (queries and `CompleteQuestController`'s invalidation)
  /// normalizes before calling this provider — see
  /// `CompleteQuestUseCase._normalizeDate` for the same convention.

  XpTransactionsForQuestAndDateProvider call(String questId, DateTime date) =>
      XpTransactionsForQuestAndDateProvider._(
        argument: (questId, date),
        from: this,
      );

  @override
  String toString() => r'xpTransactionsForQuestAndDateProvider';
}

/// Every transaction recorded on [date], across all quests. [date] must
/// already be UTC-date-normalized, for the same reason documented on
/// [xpTransactionsForQuestAndDate].

@ProviderFor(xpTransactionsForDate)
final xpTransactionsForDateProvider = XpTransactionsForDateFamily._();

/// Every transaction recorded on [date], across all quests. [date] must
/// already be UTC-date-normalized, for the same reason documented on
/// [xpTransactionsForQuestAndDate].

final class XpTransactionsForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<XpTransaction>>,
          List<XpTransaction>,
          FutureOr<List<XpTransaction>>
        >
    with
        $FutureModifier<List<XpTransaction>>,
        $FutureProvider<List<XpTransaction>> {
  /// Every transaction recorded on [date], across all quests. [date] must
  /// already be UTC-date-normalized, for the same reason documented on
  /// [xpTransactionsForQuestAndDate].
  XpTransactionsForDateProvider._({
    required XpTransactionsForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'xpTransactionsForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$xpTransactionsForDateHash();

  @override
  String toString() {
    return r'xpTransactionsForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<XpTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<XpTransaction>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return xpTransactionsForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is XpTransactionsForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$xpTransactionsForDateHash() =>
    r'f5821192f81b0569d9fa0e41ee6e03167d78ea15';

/// Every transaction recorded on [date], across all quests. [date] must
/// already be UTC-date-normalized, for the same reason documented on
/// [xpTransactionsForQuestAndDate].

final class XpTransactionsForDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<XpTransaction>>, DateTime> {
  XpTransactionsForDateFamily._()
    : super(
        retry: null,
        name: r'xpTransactionsForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every transaction recorded on [date], across all quests. [date] must
  /// already be UTC-date-normalized, for the same reason documented on
  /// [xpTransactionsForQuestAndDate].

  XpTransactionsForDateProvider call(DateTime date) =>
      XpTransactionsForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'xpTransactionsForDateProvider';
}

/// Lifetime total XP, derived fresh from the ledger every time — never a
/// stored/cached total (CLAUDE.md: "Cached XP totals are projections, not
/// the source of truth").

@ProviderFor(totalXp)
final totalXpProvider = TotalXpProvider._();

/// Lifetime total XP, derived fresh from the ledger every time — never a
/// stored/cached total (CLAUDE.md: "Cached XP totals are projections, not
/// the source of truth").

final class TotalXpProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Lifetime total XP, derived fresh from the ledger every time — never a
  /// stored/cached total (CLAUDE.md: "Cached XP totals are projections, not
  /// the source of truth").
  TotalXpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalXpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalXpHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalXp(ref);
  }
}

String _$totalXpHash() => r'24a6fff9e1675d183a0020da06585913bfa925a2';

/// Lifetime XP grouped by attribute, derived the same way — one
/// `sumXpForAttribute` call per attribute, run concurrently.

@ProviderFor(xpByAttribute)
final xpByAttributeProvider = XpByAttributeProvider._();

/// Lifetime XP grouped by attribute, derived the same way — one
/// `sumXpForAttribute` call per attribute, run concurrently.

final class XpByAttributeProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<AttributeType, int>>,
          Map<AttributeType, int>,
          FutureOr<Map<AttributeType, int>>
        >
    with
        $FutureModifier<Map<AttributeType, int>>,
        $FutureProvider<Map<AttributeType, int>> {
  /// Lifetime XP grouped by attribute, derived the same way — one
  /// `sumXpForAttribute` call per attribute, run concurrently.
  XpByAttributeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xpByAttributeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xpByAttributeHash();

  @$internal
  @override
  $FutureProviderElement<Map<AttributeType, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<AttributeType, int>> create(Ref ref) {
    return xpByAttribute(ref);
  }
}

String _$xpByAttributeHash() => r'422afd0c530f50beec0a0bc034c3fa5c5b556ee5';
