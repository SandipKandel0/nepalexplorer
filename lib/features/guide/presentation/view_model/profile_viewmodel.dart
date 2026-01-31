import 'package:flutter/foundation.dart';
import 'package:nepalexplorer/features/guide/domain/entities/guide_entity.dart';
import 'package:nepalexplorer/features/guide/domain/usecases/get_guide_profile.dart';
import 'package:nepalexplorer/features/guide/domain/usecases/update_guide_profile.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetGuideProfile getProfileUseCase;
  final UpdateGuideProfile updateProfileUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  });

  bool isLoading = false;
  GuideEntity? guide;
  String? errorMessage;

  /// Fetch profile using authId
  Future<void> fetchProfile(String authId) async {
    isLoading = true;
    notifyListeners();

    try {
      guide = await getProfileUseCase.call(authId); // ✅ must call with authId
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      guide = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile
  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
    required String languages,
    required String experience,
    String? profilePictureUrl,
  }) async {
    if (guide == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final updatedGuide = GuideEntity(
        guideId: guide!.guideId,
        authId: guide!.authId, // authId should remain unchanged
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        bio: bio,
        languages: languages.split(',').map((e) => e.trim()).toList(),
        experience: int.tryParse(experience) ?? guide!.experience,
        isAvailable: guide!.isAvailable,
        profilePictureUrl: profilePictureUrl ?? guide!.profilePictureUrl,
      );

      // Update on repository
      await updateProfileUseCase.call(updatedGuide);

      // Fetch updated profile again from repository
      guide = await getProfileUseCase.call(updatedGuide.authId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
