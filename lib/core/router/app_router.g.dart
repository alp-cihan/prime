// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [GoRouter] instance. Generated as a Riverpod provider
/// (rather than a bare top-level constant) so later phases can inject
/// auth/onboarding redirects without changing how the router is consumed.
///
/// Phase 14 onboarding gate: [AppRoutes.onboarding] is the initial location
/// exactly when [OnboardingRepository.isCompleted] is still false (a
/// synchronous read — see that repository's own doc for why); [redirect]
/// re-checks the *current* value (via `ref.read`, not a captured one) on
/// every navigation attempt, so a user who has never completed onboarding
/// can't reach a shell route by deep-linking around it, while a completed
/// user visiting `/onboarding` again (Settings' "Restart Onboarding") is
/// never redirected away from it.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's single [GoRouter] instance. Generated as a Riverpod provider
/// (rather than a bare top-level constant) so later phases can inject
/// auth/onboarding redirects without changing how the router is consumed.
///
/// Phase 14 onboarding gate: [AppRoutes.onboarding] is the initial location
/// exactly when [OnboardingRepository.isCompleted] is still false (a
/// synchronous read — see that repository's own doc for why); [redirect]
/// re-checks the *current* value (via `ref.read`, not a captured one) on
/// every navigation attempt, so a user who has never completed onboarding
/// can't reach a shell route by deep-linking around it, while a completed
/// user visiting `/onboarding` again (Settings' "Restart Onboarding") is
/// never redirected away from it.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's single [GoRouter] instance. Generated as a Riverpod provider
  /// (rather than a bare top-level constant) so later phases can inject
  /// auth/onboarding redirects without changing how the router is consumed.
  ///
  /// Phase 14 onboarding gate: [AppRoutes.onboarding] is the initial location
  /// exactly when [OnboardingRepository.isCompleted] is still false (a
  /// synchronous read — see that repository's own doc for why); [redirect]
  /// re-checks the *current* value (via `ref.read`, not a captured one) on
  /// every navigation attempt, so a user who has never completed onboarding
  /// can't reach a shell route by deep-linking around it, while a completed
  /// user visiting `/onboarding` again (Settings' "Restart Onboarding") is
  /// never redirected away from it.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'7f5591a8adc77b8aee80f8a3c3469eec6010e1c4';
