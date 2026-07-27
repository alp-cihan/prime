import '../../../../core/domain/failure.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/identity_milestone.dart';
import '../services/identity_service.dart';

/// Thin public entry point over [IdentityService.recentMilestones] — see
/// `LoadIdentitySnapshotUseCase`'s doc for why this is a real (if thin)
/// use case class rather than folded into a provider directly.
class LoadRecentMilestonesUseCase {
  const LoadRecentMilestonesUseCase({required IdentityService identityService})
    : _identityService = identityService;

  final IdentityService _identityService;

  Future<Result<List<IdentityMilestone>>> execute({int limit = 20}) async {
    try {
      return Ok(await _identityService.recentMilestones(limit: limit));
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load recent milestones: $e'));
    }
  }
}
