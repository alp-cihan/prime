// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_query_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits the current persisted quest list immediately, then again on every
/// subsequent repository change (see `HiveQuestRepository.watchAll`). This
/// is a single riverpod provider, so every widget that watches it shares
/// the one underlying `Box.watch()` subscription — no duplicate listeners
/// are created no matter how many consumers watch it.

@ProviderFor(watchAllQuests)
final watchAllQuestsProvider = WatchAllQuestsProvider._();

/// Emits the current persisted quest list immediately, then again on every
/// subsequent repository change (see `HiveQuestRepository.watchAll`). This
/// is a single riverpod provider, so every widget that watches it shares
/// the one underlying `Box.watch()` subscription — no duplicate listeners
/// are created no matter how many consumers watch it.

final class WatchAllQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Quest>>,
          List<Quest>,
          Stream<List<Quest>>
        >
    with $FutureModifier<List<Quest>>, $StreamProvider<List<Quest>> {
  /// Emits the current persisted quest list immediately, then again on every
  /// subsequent repository change (see `HiveQuestRepository.watchAll`). This
  /// is a single riverpod provider, so every widget that watches it shares
  /// the one underlying `Box.watch()` subscription — no duplicate listeners
  /// are created no matter how many consumers watch it.
  WatchAllQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAllQuestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAllQuestsHash();

  @$internal
  @override
  $StreamProviderElement<List<Quest>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Quest>> create(Ref ref) {
    return watchAllQuests(ref);
  }
}

String _$watchAllQuestsHash() => r'73f6a2a17b2061ee9938db875e51b00d3f824668';

/// Null when no quest exists for [questId] — architecture.md does not
/// define a failure object for a missing quest lookup (only
/// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
/// completion flow), so this passes `QuestRepository.getById`'s own
/// nullable result straight through.

@ProviderFor(questById)
final questByIdProvider = QuestByIdFamily._();

/// Null when no quest exists for [questId] — architecture.md does not
/// define a failure object for a missing quest lookup (only
/// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
/// completion flow), so this passes `QuestRepository.getById`'s own
/// nullable result straight through.

final class QuestByIdProvider
    extends $FunctionalProvider<AsyncValue<Quest?>, Quest?, FutureOr<Quest?>>
    with $FutureModifier<Quest?>, $FutureProvider<Quest?> {
  /// Null when no quest exists for [questId] — architecture.md does not
  /// define a failure object for a missing quest lookup (only
  /// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
  /// completion flow), so this passes `QuestRepository.getById`'s own
  /// nullable result straight through.
  QuestByIdProvider._({
    required QuestByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questByIdHash();

  @override
  String toString() {
    return r'questByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Quest?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Quest?> create(Ref ref) {
    final argument = this.argument as String;
    return questById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questByIdHash() => r'fff81a0b1d4d73474b241f487bf024c62cdce373';

/// Null when no quest exists for [questId] — architecture.md does not
/// define a failure object for a missing quest lookup (only
/// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
/// completion flow), so this passes `QuestRepository.getById`'s own
/// nullable result straight through.

final class QuestByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Quest?>, String> {
  QuestByIdFamily._()
    : super(
        retry: null,
        name: r'questByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Null when no quest exists for [questId] — architecture.md does not
  /// define a failure object for a missing quest lookup (only
  /// `CompleteQuestUseCase`'s own `NotFoundFailure`, which is specific to the
  /// completion flow), so this passes `QuestRepository.getById`'s own
  /// nullable result straight through.

  QuestByIdProvider call(String questId) =>
      QuestByIdProvider._(argument: questId, from: this);

  @override
  String toString() => r'questByIdProvider';
}

/// Progress for one `(questId, date)`. [date] must already be
/// UTC-date-normalized for the same reason documented on
/// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
/// exact [date] value passed in.

@ProviderFor(questProgressForDate)
final questProgressForDateProvider = QuestProgressForDateFamily._();

/// Progress for one `(questId, date)`. [date] must already be
/// UTC-date-normalized for the same reason documented on
/// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
/// exact [date] value passed in.

final class QuestProgressForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<QuestProgress?>,
          QuestProgress?,
          FutureOr<QuestProgress?>
        >
    with $FutureModifier<QuestProgress?>, $FutureProvider<QuestProgress?> {
  /// Progress for one `(questId, date)`. [date] must already be
  /// UTC-date-normalized for the same reason documented on
  /// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
  /// exact [date] value passed in.
  QuestProgressForDateProvider._({
    required QuestProgressForDateFamily super.from,
    required (String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'questProgressForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questProgressForDateHash();

  @override
  String toString() {
    return r'questProgressForDateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<QuestProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<QuestProgress?> create(Ref ref) {
    final argument = this.argument as (String, DateTime);
    return questProgressForDate(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestProgressForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questProgressForDateHash() =>
    r'6082309b876b9770961b6df24454367786fb3f04';

/// Progress for one `(questId, date)`. [date] must already be
/// UTC-date-normalized for the same reason documented on
/// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
/// exact [date] value passed in.

final class QuestProgressForDateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<QuestProgress?>,
          (String, DateTime)
        > {
  QuestProgressForDateFamily._()
    : super(
        retry: null,
        name: r'questProgressForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Progress for one `(questId, date)`. [date] must already be
  /// UTC-date-normalized for the same reason documented on
  /// `xpTransactionsForQuestAndDateProvider` — the family cache key is the
  /// exact [date] value passed in.

  QuestProgressForDateProvider call(String questId, DateTime date) =>
      QuestProgressForDateProvider._(argument: (questId, date), from: this);

  @override
  String toString() => r'questProgressForDateProvider';
}
