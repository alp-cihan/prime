// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localeRepository)
final localeRepositoryProvider = LocaleRepositoryProvider._();

final class LocaleRepositoryProvider
    extends
        $FunctionalProvider<
          LocaleRepository,
          LocaleRepository,
          LocaleRepository
        >
    with $Provider<LocaleRepository> {
  LocaleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocaleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocaleRepository create(Ref ref) {
    return localeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocaleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocaleRepository>(value),
    );
  }
}

String _$localeRepositoryHash() => r'037f4aed674b2d6fce45c769c774ac4c4b4ad44a';

/// The user's current language choice — read synchronously from Hive at
/// construction (mirrors `OnboardingRepository`'s "no loading state" design;
/// see that repository's own doc for why) so `MaterialApp.router`'s
/// `locale:` can watch this directly with no splash/loading gap, and so
/// changing it updates the UI live without a restart.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The user's current language choice — read synchronously from Hive at
/// construction (mirrors `OnboardingRepository`'s "no loading state" design;
/// see that repository's own doc for why) so `MaterialApp.router`'s
/// `locale:` can watch this directly with no splash/loading gap, and so
/// changing it updates the UI live without a restart.
final class LocaleControllerProvider
    extends $NotifierProvider<LocaleController, AppLocaleOption> {
  /// The user's current language choice — read synchronously from Hive at
  /// construction (mirrors `OnboardingRepository`'s "no loading state" design;
  /// see that repository's own doc for why) so `MaterialApp.router`'s
  /// `locale:` can watch this directly with no splash/loading gap, and so
  /// changing it updates the UI live without a restart.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocaleOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocaleOption>(value),
    );
  }
}

String _$localeControllerHash() => r'bd29eed808be3ecdc212be37cf545e1a9433ead9';

/// The user's current language choice — read synchronously from Hive at
/// construction (mirrors `OnboardingRepository`'s "no loading state" design;
/// see that repository's own doc for why) so `MaterialApp.router`'s
/// `locale:` can watch this directly with no splash/loading gap, and so
/// changing it updates the UI live without a restart.

abstract class _$LocaleController extends $Notifier<AppLocaleOption> {
  AppLocaleOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLocaleOption, AppLocaleOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLocaleOption, AppLocaleOption>,
              AppLocaleOption,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
