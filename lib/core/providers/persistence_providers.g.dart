// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistence_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exposes the three Hive boxes opened once by `bootstrapHive()` at app
/// startup. These providers never open, close, or otherwise own the box
/// lifecycle themselves — they only read the already-open box — so
/// disposing a provider (or a test container) never closes a box owned by
/// app bootstrap. `keepAlive: true` because each box is a singleton for the
/// app's lifetime; nothing about a box should be recreated mid-session.
///
/// Tests override these three providers directly with real temporary Hive
/// boxes (see test/support/hive_test_support.dart) rather than going
/// through `bootstrapHive()`, which requires the Flutter plugin channel.

@ProviderFor(questHiveBox)
final questHiveBoxProvider = QuestHiveBoxProvider._();

/// Exposes the three Hive boxes opened once by `bootstrapHive()` at app
/// startup. These providers never open, close, or otherwise own the box
/// lifecycle themselves — they only read the already-open box — so
/// disposing a provider (or a test container) never closes a box owned by
/// app bootstrap. `keepAlive: true` because each box is a singleton for the
/// app's lifetime; nothing about a box should be recreated mid-session.
///
/// Tests override these three providers directly with real temporary Hive
/// boxes (see test/support/hive_test_support.dart) rather than going
/// through `bootstrapHive()`, which requires the Flutter plugin channel.

final class QuestHiveBoxProvider
    extends
        $FunctionalProvider<
          Box<QuestHiveModel>,
          Box<QuestHiveModel>,
          Box<QuestHiveModel>
        >
    with $Provider<Box<QuestHiveModel>> {
  /// Exposes the three Hive boxes opened once by `bootstrapHive()` at app
  /// startup. These providers never open, close, or otherwise own the box
  /// lifecycle themselves — they only read the already-open box — so
  /// disposing a provider (or a test container) never closes a box owned by
  /// app bootstrap. `keepAlive: true` because each box is a singleton for the
  /// app's lifetime; nothing about a box should be recreated mid-session.
  ///
  /// Tests override these three providers directly with real temporary Hive
  /// boxes (see test/support/hive_test_support.dart) rather than going
  /// through `bootstrapHive()`, which requires the Flutter plugin channel.
  QuestHiveBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questHiveBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questHiveBoxHash();

  @$internal
  @override
  $ProviderElement<Box<QuestHiveModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<QuestHiveModel> create(Ref ref) {
    return questHiveBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<QuestHiveModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<QuestHiveModel>>(value),
    );
  }
}

String _$questHiveBoxHash() => r'7f11c4ade2ef867eb9bdd80c0a9c10b80d4fd1bd';

@ProviderFor(questProgressHiveBox)
final questProgressHiveBoxProvider = QuestProgressHiveBoxProvider._();

final class QuestProgressHiveBoxProvider
    extends
        $FunctionalProvider<
          Box<QuestProgressHiveModel>,
          Box<QuestProgressHiveModel>,
          Box<QuestProgressHiveModel>
        >
    with $Provider<Box<QuestProgressHiveModel>> {
  QuestProgressHiveBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questProgressHiveBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questProgressHiveBoxHash();

  @$internal
  @override
  $ProviderElement<Box<QuestProgressHiveModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<QuestProgressHiveModel> create(Ref ref) {
    return questProgressHiveBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<QuestProgressHiveModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<QuestProgressHiveModel>>(value),
    );
  }
}

String _$questProgressHiveBoxHash() =>
    r'bd3cc60723ecd589ccf680428a7011b5cf71bc93';

@ProviderFor(xpTransactionHiveBox)
final xpTransactionHiveBoxProvider = XpTransactionHiveBoxProvider._();

final class XpTransactionHiveBoxProvider
    extends
        $FunctionalProvider<
          Box<XpTransactionHiveModel>,
          Box<XpTransactionHiveModel>,
          Box<XpTransactionHiveModel>
        >
    with $Provider<Box<XpTransactionHiveModel>> {
  XpTransactionHiveBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'xpTransactionHiveBoxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$xpTransactionHiveBoxHash();

  @$internal
  @override
  $ProviderElement<Box<XpTransactionHiveModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Box<XpTransactionHiveModel> create(Ref ref) {
    return xpTransactionHiveBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Box<XpTransactionHiveModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Box<XpTransactionHiveModel>>(value),
    );
  }
}

String _$xpTransactionHiveBoxHash() =>
    r'866df41bee526d85b8c7098d5307f8f6345cd330';
