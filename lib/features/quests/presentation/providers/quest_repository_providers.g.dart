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

/// Phase 9 — the occurrence model's pure-domain policy (boundaries,
/// eligibility, anchor dates) and its application-layer composition with the
/// XP ledger (repeat index, prior-XP-this-occurrence, first-completion-ever).

@ProviderFor(questOccurrencePolicy)
final questOccurrencePolicyProvider = QuestOccurrencePolicyProvider._();

/// Phase 9 — the occurrence model's pure-domain policy (boundaries,
/// eligibility, anchor dates) and its application-layer composition with the
/// XP ledger (repeat index, prior-XP-this-occurrence, first-completion-ever).

final class QuestOccurrencePolicyProvider
    extends
        $FunctionalProvider<
          QuestOccurrencePolicy,
          QuestOccurrencePolicy,
          QuestOccurrencePolicy
        >
    with $Provider<QuestOccurrencePolicy> {
  /// Phase 9 — the occurrence model's pure-domain policy (boundaries,
  /// eligibility, anchor dates) and its application-layer composition with the
  /// XP ledger (repeat index, prior-XP-this-occurrence, first-completion-ever).
  QuestOccurrencePolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questOccurrencePolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questOccurrencePolicyHash();

  @$internal
  @override
  $ProviderElement<QuestOccurrencePolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestOccurrencePolicy create(Ref ref) {
    return questOccurrencePolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestOccurrencePolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestOccurrencePolicy>(value),
    );
  }
}

String _$questOccurrencePolicyHash() =>
    r'f327174b45980dd93067194ec90eb200813a41a2';

@ProviderFor(questOccurrenceService)
final questOccurrenceServiceProvider = QuestOccurrenceServiceProvider._();

final class QuestOccurrenceServiceProvider
    extends
        $FunctionalProvider<
          QuestOccurrenceService,
          QuestOccurrenceService,
          QuestOccurrenceService
        >
    with $Provider<QuestOccurrenceService> {
  QuestOccurrenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questOccurrenceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questOccurrenceServiceHash();

  @$internal
  @override
  $ProviderElement<QuestOccurrenceService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestOccurrenceService create(Ref ref) {
    return questOccurrenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestOccurrenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestOccurrenceService>(value),
    );
  }
}

String _$questOccurrenceServiceHash() =>
    r'99e0c1c904f2f896f7dfc680811822d7b37c9e61';

/// The date to read/write a given [repeatability]'s `QuestProgress` under
/// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
/// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
/// must never calculate dates"). Backed by [clockProvider] for the same
/// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
/// (not by quest id) since the anchor date only depends on the cadence and
/// the clock — every quest sharing a cadence shares the same anchor, so
/// Riverpod caches and invalidates exactly one instance per cadence.

@ProviderFor(questOccurrenceAnchorDate)
final questOccurrenceAnchorDateProvider = QuestOccurrenceAnchorDateFamily._();

/// The date to read/write a given [repeatability]'s `QuestProgress` under
/// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
/// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
/// must never calculate dates"). Backed by [clockProvider] for the same
/// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
/// (not by quest id) since the anchor date only depends on the cadence and
/// the clock — every quest sharing a cadence shares the same anchor, so
/// Riverpod caches and invalidates exactly one instance per cadence.

final class QuestOccurrenceAnchorDateProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The date to read/write a given [repeatability]'s `QuestProgress` under
  /// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
  /// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
  /// must never calculate dates"). Backed by [clockProvider] for the same
  /// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
  /// (not by quest id) since the anchor date only depends on the cadence and
  /// the clock — every quest sharing a cadence shares the same anchor, so
  /// Riverpod caches and invalidates exactly one instance per cadence.
  QuestOccurrenceAnchorDateProvider._({
    required QuestOccurrenceAnchorDateFamily super.from,
    required Repeatability super.argument,
  }) : super(
         retry: null,
         name: r'questOccurrenceAnchorDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questOccurrenceAnchorDateHash();

  @override
  String toString() {
    return r'questOccurrenceAnchorDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    final argument = this.argument as Repeatability;
    return questOccurrenceAnchorDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuestOccurrenceAnchorDateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questOccurrenceAnchorDateHash() =>
    r'f46ebe4c611cafe4740cbbdc98c6ba1b19efc6d1';

/// The date to read/write a given [repeatability]'s `QuestProgress` under
/// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
/// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
/// must never calculate dates"). Backed by [clockProvider] for the same
/// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
/// (not by quest id) since the anchor date only depends on the cadence and
/// the clock — every quest sharing a cadence shares the same anchor, so
/// Riverpod caches and invalidates exactly one instance per cadence.

final class QuestOccurrenceAnchorDateFamily extends $Family
    with $FunctionalFamilyOverride<DateTime, Repeatability> {
  QuestOccurrenceAnchorDateFamily._()
    : super(
        retry: null,
        name: r'questOccurrenceAnchorDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The date to read/write a given [repeatability]'s `QuestProgress` under
  /// right now — a UI-facing wrapper over [QuestOccurrencePolicy.resolve], so
  /// no widget ever computes an occurrence boundary itself (Phase 9: "Widgets
  /// must never calculate dates"). Backed by [clockProvider] for the same
  /// testability reason as [todayUtcProvider]. Keyed by [Repeatability] alone
  /// (not by quest id) since the anchor date only depends on the cadence and
  /// the clock — every quest sharing a cadence shares the same anchor, so
  /// Riverpod caches and invalidates exactly one instance per cadence.

  QuestOccurrenceAnchorDateProvider call(Repeatability repeatability) =>
      QuestOccurrenceAnchorDateProvider._(argument: repeatability, from: this);

  @override
  String toString() => r'questOccurrenceAnchorDateProvider';
}

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
    r'40e0891b23cb1d123814155b25e2c1ef80d43167';

@ProviderFor(idGenerator)
final idGeneratorProvider = IdGeneratorProvider._();

final class IdGeneratorProvider
    extends $FunctionalProvider<IdGenerator, IdGenerator, IdGenerator>
    with $Provider<IdGenerator> {
  IdGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idGeneratorHash();

  @$internal
  @override
  $ProviderElement<IdGenerator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IdGenerator create(Ref ref) {
    return idGenerator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdGenerator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdGenerator>(value),
    );
  }
}

String _$idGeneratorHash() => r'dcb1b7c4318ee07437d5d1b3f8434b02753607ed';

@ProviderFor(questInputValidator)
final questInputValidatorProvider = QuestInputValidatorProvider._();

final class QuestInputValidatorProvider
    extends
        $FunctionalProvider<
          QuestInputValidator,
          QuestInputValidator,
          QuestInputValidator
        >
    with $Provider<QuestInputValidator> {
  QuestInputValidatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questInputValidatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questInputValidatorHash();

  @$internal
  @override
  $ProviderElement<QuestInputValidator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestInputValidator create(Ref ref) {
    return questInputValidator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestInputValidator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestInputValidator>(value),
    );
  }
}

String _$questInputValidatorHash() =>
    r'08233378c2842adda6205530e8417b550b5c6239';

/// Phase 7 write-side use cases — composed from the same repository/service
/// singletons above, kept alive for the same reasons as
/// [completeQuestUseCaseProvider].

@ProviderFor(createQuestUseCase)
final createQuestUseCaseProvider = CreateQuestUseCaseProvider._();

/// Phase 7 write-side use cases — composed from the same repository/service
/// singletons above, kept alive for the same reasons as
/// [completeQuestUseCaseProvider].

final class CreateQuestUseCaseProvider
    extends
        $FunctionalProvider<
          CreateQuestUseCase,
          CreateQuestUseCase,
          CreateQuestUseCase
        >
    with $Provider<CreateQuestUseCase> {
  /// Phase 7 write-side use cases — composed from the same repository/service
  /// singletons above, kept alive for the same reasons as
  /// [completeQuestUseCaseProvider].
  CreateQuestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createQuestUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createQuestUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateQuestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateQuestUseCase create(Ref ref) {
    return createQuestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateQuestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateQuestUseCase>(value),
    );
  }
}

String _$createQuestUseCaseHash() =>
    r'9a99ab93feae3b669a5a67b7ad8d03a6f1098bf0';

@ProviderFor(updateQuestUseCase)
final updateQuestUseCaseProvider = UpdateQuestUseCaseProvider._();

final class UpdateQuestUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateQuestUseCase,
          UpdateQuestUseCase,
          UpdateQuestUseCase
        >
    with $Provider<UpdateQuestUseCase> {
  UpdateQuestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateQuestUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateQuestUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateQuestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateQuestUseCase create(Ref ref) {
    return updateQuestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateQuestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateQuestUseCase>(value),
    );
  }
}

String _$updateQuestUseCaseHash() =>
    r'1cf86ceea7441574912ae8b5dc2ef92eb8d56732';

@ProviderFor(deleteQuestUseCase)
final deleteQuestUseCaseProvider = DeleteQuestUseCaseProvider._();

final class DeleteQuestUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteQuestUseCase,
          DeleteQuestUseCase,
          DeleteQuestUseCase
        >
    with $Provider<DeleteQuestUseCase> {
  DeleteQuestUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteQuestUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteQuestUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteQuestUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteQuestUseCase create(Ref ref) {
    return deleteQuestUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteQuestUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteQuestUseCase>(value),
    );
  }
}

String _$deleteQuestUseCaseHash() =>
    r'3573795b07b45a69ff47a791ac91b019c5be52ce';

@ProviderFor(questProgressPolicy)
final questProgressPolicyProvider = QuestProgressPolicyProvider._();

final class QuestProgressPolicyProvider
    extends
        $FunctionalProvider<
          QuestProgressPolicy,
          QuestProgressPolicy,
          QuestProgressPolicy
        >
    with $Provider<QuestProgressPolicy> {
  QuestProgressPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questProgressPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questProgressPolicyHash();

  @$internal
  @override
  $ProviderElement<QuestProgressPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestProgressPolicy create(Ref ref) {
    return questProgressPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestProgressPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestProgressPolicy>(value),
    );
  }
}

String _$questProgressPolicyHash() =>
    r'1c23c1133e80a2450986deddb06797dfe29cc54c';

/// Phase 8's progress-mutation use case — composed from the same
/// repository singletons plus [completeQuestUseCaseProvider], which it
/// delegates every completion to (see that use case's own doc for why it
/// never awards XP itself).

@ProviderFor(updateQuestProgressUseCase)
final updateQuestProgressUseCaseProvider =
    UpdateQuestProgressUseCaseProvider._();

/// Phase 8's progress-mutation use case — composed from the same
/// repository singletons plus [completeQuestUseCaseProvider], which it
/// delegates every completion to (see that use case's own doc for why it
/// never awards XP itself).

final class UpdateQuestProgressUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateQuestProgressUseCase,
          UpdateQuestProgressUseCase,
          UpdateQuestProgressUseCase
        >
    with $Provider<UpdateQuestProgressUseCase> {
  /// Phase 8's progress-mutation use case — composed from the same
  /// repository singletons plus [completeQuestUseCaseProvider], which it
  /// delegates every completion to (see that use case's own doc for why it
  /// never awards XP itself).
  UpdateQuestProgressUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateQuestProgressUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateQuestProgressUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateQuestProgressUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateQuestProgressUseCase create(Ref ref) {
    return updateQuestProgressUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateQuestProgressUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateQuestProgressUseCase>(value),
    );
  }
}

String _$updateQuestProgressUseCaseHash() =>
    r'243a4ee0de9f681def466d264189f194b1b466b4';
