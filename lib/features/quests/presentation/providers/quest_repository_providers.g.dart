// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Singletons for the app's lifetime — each wraps an already-open Hive box
/// (see `persistence_providers.dart`) and holds no other state, so there is
/// nothing to reset or leak by keeping exactly one instance alive.

@ProviderFor(questRepository)
final questRepositoryProvider = QuestRepositoryProvider._();

/// Singletons for the app's lifetime — each wraps an already-open Hive box
/// (see `persistence_providers.dart`) and holds no other state, so there is
/// nothing to reset or leak by keeping exactly one instance alive.

final class QuestRepositoryProvider
    extends
        $FunctionalProvider<QuestRepository, QuestRepository, QuestRepository>
    with $Provider<QuestRepository> {
  /// Singletons for the app's lifetime — each wraps an already-open Hive box
  /// (see `persistence_providers.dart`) and holds no other state, so there is
  /// nothing to reset or leak by keeping exactly one instance alive.
  QuestRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuestRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuestRepository create(Ref ref) {
    return questRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestRepository>(value),
    );
  }
}

String _$questRepositoryHash() => r'e3ecf420630be444ccf8e73177a7058dafaefc0c';

@ProviderFor(questProgressRepository)
final questProgressRepositoryProvider = QuestProgressRepositoryProvider._();

final class QuestProgressRepositoryProvider
    extends
        $FunctionalProvider<
          QuestProgressRepository,
          QuestProgressRepository,
          QuestProgressRepository
        >
    with $Provider<QuestProgressRepository> {
  QuestProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questProgressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuestProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestProgressRepository create(Ref ref) {
    return questProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestProgressRepository>(value),
    );
  }
}

String _$questProgressRepositoryHash() =>
    r'b4bcc6385a82adfe522c19820927fdcf5867ae76';

@ProviderFor(clock)
final clockProvider = ClockProvider._();

final class ClockProvider extends $FunctionalProvider<Clock, Clock, Clock>
    with $Provider<Clock> {
  ClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clockHash();

  @$internal
  @override
  $ProviderElement<Clock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Clock create(Ref ref) {
    return clock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Clock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Clock>(value),
    );
  }
}

String _$clockHash() => r'55214d6539f7396a3ae1aa23b06eea79fdac0ebe';

/// Today, normalized to a UTC date-only value — the same normalization
/// `CompleteQuestUseCase` and the Hive repositories already apply. Backed by
/// [clockProvider] so overriding that one provider in tests (a fixed
/// [Clock]) deterministically controls "today" everywhere in the UI too.

@ProviderFor(todayUtc)
final todayUtcProvider = TodayUtcProvider._();

/// Today, normalized to a UTC date-only value — the same normalization
/// `CompleteQuestUseCase` and the Hive repositories already apply. Backed by
/// [clockProvider] so overriding that one provider in tests (a fixed
/// [Clock]) deterministically controls "today" everywhere in the UI too.

final class TodayUtcProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// Today, normalized to a UTC date-only value — the same normalization
  /// `CompleteQuestUseCase` and the Hive repositories already apply. Backed by
  /// [clockProvider] so overriding that one provider in tests (a fixed
  /// [Clock]) deterministically controls "today" everywhere in the UI too.
  TodayUtcProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayUtcProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayUtcHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return todayUtc(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$todayUtcHash() => r'994d98f891eefe47161ba155b9a42f6c923f16d9';

@ProviderFor(questXpCalculator)
final questXpCalculatorProvider = QuestXpCalculatorProvider._();

final class QuestXpCalculatorProvider
    extends
        $FunctionalProvider<
          QuestXpCalculator,
          QuestXpCalculator,
          QuestXpCalculator
        >
    with $Provider<QuestXpCalculator> {
  QuestXpCalculatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questXpCalculatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questXpCalculatorHash();

  @$internal
  @override
  $ProviderElement<QuestXpCalculator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestXpCalculator create(Ref ref) {
    return questXpCalculator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestXpCalculator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestXpCalculator>(value),
    );
  }
}

String _$questXpCalculatorHash() => r'd10262f22cec005a92d641d1554916de257842cd';

/// Composes the quest-completion use case from the repository/service
/// singletons above plus [xpLedgerRepositoryProvider] (xp_ledger feature).
/// `CompleteQuestUseCase` itself holds no mutable state, so recreating it
/// costs nothing, but it is kept alive for consistency with its
/// dependencies and to avoid rebuilding it on every unrelated rebuild.

@ProviderFor(completeQuestUseCase)
final completeQuestUseCaseProvider = CompleteQuestUseCaseProvider._();

/// Composes the quest-completion use case from the repository/service
/// singletons above plus [xpLedgerRepositoryProvider] (xp_ledger feature).
/// `CompleteQuestUseCase` itself holds no mutable state, so recreating it
/// costs nothing, but it is kept alive for consistency with its
/// dependencies and to avoid rebuilding it on every unrelated rebuild.

final class CompleteQuestUseCaseProvider
    extends
        $FunctionalProvider<
          CompleteQuestUseCase,
          CompleteQuestUseCase,
          CompleteQuestUseCase
        >
    with $Provider<CompleteQuestUseCase> {
  /// Composes the quest-completion use case from the repository/service
  /// singletons above plus [xpLedgerRepositoryProvider] (xp_ledger feature).
  /// `CompleteQuestUseCase` itself holds no mutable state, so recreating it
  /// costs nothing, but it is kept alive for consistency with its
  /// dependencies and to avoid rebuilding it on every unrelated rebuild.
  CompleteQuestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completeQuestUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completeQuestUseCaseHash();

  @$internal
  @override
  $ProviderElement<CompleteQuestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompleteQuestUseCase create(Ref ref) {
    return completeQuestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompleteQuestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompleteQuestUseCase>(value),
    );
  }
}

String _$completeQuestUseCaseHash() =>
    r'de99bdc03148ed2eef37c21929d2f9cb62cfa756';
