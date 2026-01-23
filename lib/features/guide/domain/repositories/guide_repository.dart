import '../entities/guide_entity.dart';

abstract class GuideRepository {
  Future<GuideEntity> getGuideProfile(String authId);
  Future<void> updateGuideProfile(GuideEntity guide);
}
