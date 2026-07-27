// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clearLocalDataUseCase)
final clearLocalDataUseCaseProvider = ClearLocalDataUseCaseProvider._();

final class ClearLocalDataUseCaseProvider
    extends
        $FunctionalProvider<
          ClearLocalDataUseCase,
          ClearLocalDataUseCase,
          ClearLocalDataUseCase
        >
    with $Provider<ClearLocalDataUseCase> {
  ClearLocalDataUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearLocalDataUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearLocalDataUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearLocalDataUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearLocalDataUseCase create(Ref ref) {
    return clearLocalDataUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearLocalDataUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearLocalDataUseCase>(value),
    );
  }
}

String _$clearLocalDataUseCaseHash() =>
    r'dee3ccd2e914f262ac7fae815ff1208c44014c31';
