import 'package:nepalexplorer/features/guide/data/datasources/local/guide_local_datasource.dart';
import 'package:nepalexplorer/features/guide/data/datasources/remote/guide_remote_datasource.dart';

import '../../domain/entities/guide_entity.dart';
import '../../domain/repositories/guide_repository.dart';
import '../models/guide_model.dart';

class GuideRepositoryImpl implements GuideRepository {
  final GuideRemoteDatasource remote;
  final GuideLocalDataSource local;
  final String token;

  GuideRepositoryImpl({
    required this.remote,
    required this.local,
    required this.token,
  });

  @override
  Future<GuideEntity> getGuideProfile(String authId) async {
    // 1️⃣ Check local cache
    final localData = await local.getGuideProfile(authId);
    if (localData != null) return localData.toEntity();

    // 2️⃣ Fetch from remote
    final remoteData = await remote.getGuideProfile(token);

    // 3️⃣ Save to local cache
    await local.saveGuideProfile(remoteData);

    return remoteData.toEntity();
  }

  @override
  Future<void> updateGuideProfile(GuideEntity guide) async {
    // Convert entity to model
    final model = GuideModel(
      guideId: guide.guideId,
      authId: guide.authId,
      fullName: guide.fullName,
      email: guide.email,
      phoneNumber: guide.phoneNumber,
      experience: guide.experience,
      languages: guide.languages,
      bio: guide.bio,
      isAvailable: guide.isAvailable,
      profilePictureUrl: guide.profilePictureUrl,
    );

    // 1️⃣ Update on remote
    await remote.updateGuideProfile(token, model);

    // 2️⃣ Save to local cache
    await local.saveGuideProfile(model);
  }
}
