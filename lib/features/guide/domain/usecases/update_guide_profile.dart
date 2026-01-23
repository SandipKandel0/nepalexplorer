import '../entities/guide_entity.dart';
import '../repositories/guide_repository.dart';

class UpdateGuideProfile {
  final GuideRepository repository;

  UpdateGuideProfile(this.repository);

  Future<void> call(GuideEntity guide) {
    return repository.updateGuideProfile(guide);
  }
}
