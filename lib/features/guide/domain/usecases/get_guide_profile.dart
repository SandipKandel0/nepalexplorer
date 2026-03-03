import '../entities/guide_entity.dart';
import '../repositories/guide_repository.dart';

/// UseCase: Get Guide Profile
/// Fetches the profile of a guide using the authId
class GetGuideProfile {
  final GuideRepository repository;

  GetGuideProfile(this.repository);

  /// Call with authId of the logged-in guide
  Future<GuideEntity> call(String authId) {
    return repository.getGuideProfile(authId);
  }
}
