import 'package:nepalexplorer/features/guide/data/datasources/local/guide_local_datasource.dart';
import 'package:nepalexplorer/features/guide/data/datasources/remote/guide_remote_datasource.dart';

import '../../domain/entities/guide_entity.dart';
import '../../domain/repositories/guide_repository.dart';
import '../models/guide_model.dart';

class GuideRepositoryImpl implements GuideRepository {
  final GuideRemoteDatasource remote;
  final GuideLocalDataSource local;

  GuideRepositoryImpl({required this.remote, required this.local});

  @override
  Future<GuideEntity> getGuideProfile(String authId) async {
    // 1️⃣ Check local cache
    final localData = await local.getGuideProfile(authId);
    if (localData != null) return localData;

    // 2️⃣ Fetch from remote
    final remoteDataJson = await remote.getGuideProfile(authId); // Map<String, dynamic>

    // 3️⃣ Convert JSON to GuideModel
    final remoteData = GuideModel.fromJson(remoteDataJson);

    // 4️⃣ Save to local cache
    await local.saveGuideProfile(remoteData);

    return remoteData;
  }

  @override
  Future<void> updateGuideProfile(GuideEntity guide) async {
    // Convert entity to model
    final model = GuideModel(
      guideId: guide.guideId,
      authId: guide.authId,
      experience: guide.experience,
      languages: guide.languages,
      bio: guide.bio,
      rating: guide.rating,
      isAvailable: guide.isAvailable,
    );

    // 1️⃣ Update on remote
    await remote.updateGuideProfile(model);

    // 2️⃣ Save to local cache
    await local.saveGuideProfile(model);
  }
}
