import '../entities/guide_entity.dart';
import '../repositories/guide_repository.dart';

/// UseCase: Update Guide Profile
/// Updates guide profile information
class UpdateGuideProfile {
  final GuideRepository repository;

  UpdateGuideProfile(this.repository);

  /// Call with updated GuideEntity
  Future<void> call(GuideEntity guide) {
    return repository.updateGuideProfile(guide);
  }
}
