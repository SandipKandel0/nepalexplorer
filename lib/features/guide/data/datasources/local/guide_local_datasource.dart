import 'package:hive/hive.dart';
import 'package:nepalexplorer/features/guide/data/models/guide_model.dart';


abstract class GuideLocalDataSource {
  Future<GuideModel?> getGuideProfile(String authId);
  Future<void> saveGuideProfile(GuideModel guide);
}

class GuideLocalDataSourceImpl implements GuideLocalDataSource {
  final Box box;

  GuideLocalDataSourceImpl(this.box);

  @override
  Future<GuideModel?> getGuideProfile(String authId) async {
    final json = box.get(authId);
    if (json != null) return GuideModel.fromJson(Map<String, dynamic>.from(json));
    return null;
  }

  @override
  Future<void> saveGuideProfile(GuideModel guide) async {
    await box.put(guide.authId, guide.toJson());
  }
}
