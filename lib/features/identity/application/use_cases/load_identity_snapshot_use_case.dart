import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/identity_snapshot.dart';
import '../services/identity_service.dart';

/// Thin public entry point over [IdentityService.buildSnapshot] — the
/// service owns the actual assembly logic (per the Phase 12 brief: "Create
/// an IdentityService responsible for assembling the snapshot"); this use
/// case exists because "loading identity snapshot" was asked for as its
/// own explicit use case, and unlike Phases 10/11 there is no
/// evaluate-then-persist operation to consolidate it into — the identity
/// feature has no write side at all.
class LoadIdentitySnapshotUseCase {
  const LoadIdentitySnapshotUseCase({required IdentityService identityService})
    : _identityService = identityService;

  final IdentityService _identityService;

  Future<Result<IdentitySnapshot>> execute() async {
    try {
      return Ok(await _identityService.buildSnapshot());
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load identity snapshot: $e'));
    }
  }
}
