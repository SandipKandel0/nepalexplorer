import '../entities/guide_entity.dart';
import '../repositories/guide_repository.dart';

class GetGuideProfile {
  final GuideRepository repository;

  GetGuideProfile(this.repository);

  Future<GuideEntity> call(String authId) {
    return repository.getGuideProfile(authId);
  }
}
