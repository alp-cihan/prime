// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Today dashboard's Player Header numbers, derived from
/// [totalXpProvider] via the pure [LevelCurve] — no value here is ever
/// persisted or computed any other way.

@ProviderFor(playerLevelSummary)
final playerLevelSummaryProvider = PlayerLevelSummaryProvider._();

/// The Today dashboard's Player Header numbers, derived from
/// [totalXpProvider] via the pure [LevelCurve] — no value here is ever
/// persisted or computed any other way.

final class PlayerLevelSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlayerLevelSummary>,
          PlayerLevelSummary,
          FutureOr<PlayerLevelSummary>
        >
    with
        $FutureModifier<PlayerLevelSummary>,
        $FutureProvider<PlayerLevelSummary> {
  /// The Today dashboard's Player Header numbers, derived from
  /// [totalXpProvider] via the pure [LevelCurve] — no value here is ever
  /// persisted or computed any other way.
  PlayerLevelSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playerLevelSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playerLevelSummaryHash();

  @$internal
  @override
  $FutureProviderElement<PlayerLevelSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlayerLevelSummary> create(Ref ref) {
    return playerLevelSummary(ref);
  }
}

String _$playerLevelSummaryHash() =>
    r'e82e4f08145446ac345334720e16dde006e88fff';
