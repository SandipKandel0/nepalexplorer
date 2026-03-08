import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/guide/domain/entities/guide_entity.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

// Provider for ProfileViewModel
final profileViewModelProvider = ChangeNotifierProvider<ProfileViewModel>(
  (ref) => ProfileViewModel(),
);

class ProfileViewModel extends ChangeNotifier {
  late ApiClient _apiClient;
  
  ProfileViewModel({ApiClient? apiClient}) {
    _apiClient = apiClient ?? ApiClient();
  }

  bool isLoading = false;
  GuideEntity? guide;
  String? errorMessage;

  /// Fetch profile from API
  Future<void> fetchProfile(String authId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.guideProfile);
      
      if (response.statusCode == 200) {
        final guideData = response.data['data']['guide'];
        final userData = response.data['data']['user'];
        
        // Create GuideEntity from response
        guide = GuideEntity(
          authId: userData['_id'] ?? '',
          fullName: userData['fullName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          bio: guideData['bio'] ?? '',
          languages: _parseLanguages(guideData['languages']),
          experience: guideData['experience'] ?? 0,
          profilePictureUrl: guideData['profilePicture'],
        );
        errorMessage = null;
      } else {
        errorMessage = 'Failed to load profile';
        guide = null;
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
      guide = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Parse languages from array or comma-separated string
  List<String> _parseLanguages(dynamic languages) {
    if (languages == null) return [];
    if (languages is List) {
      return List<String>.from(languages);
    }
    if (languages is String) {
      return languages.split(',').map((l) => l.trim()).toList();
    }
    return [];
  }

  /// Update profile with optional file upload
  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
    required String languages,
    required String experience,
    String? profilePicturePath,
    Uint8List? profilePictureBytes,
    String? profilePictureName,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      FormData formData = FormData.fromMap({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'bio': bio,
        'languages': languages,
        'experience': experience,
      });

      // Add profile picture using bytes (web) or file path (mobile/desktop)
      if (profilePictureBytes != null && profilePictureBytes.isNotEmpty) {
        formData = FormData.fromMap({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'bio': bio,
          'languages': languages,
          'experience': experience,
          'profilePicture': MultipartFile.fromBytes(
            profilePictureBytes,
            filename: profilePictureName ?? 'profile.jpg',
          ),
        });
      } else if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        formData = FormData.fromMap({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'bio': bio,
          'languages': languages,
          'experience': experience,
          'profilePicture': await MultipartFile.fromFile(
            profilePicturePath,
            filename: profilePicturePath.split('/').last,
          ),
        });
      }

      final response = await _apiClient.uploadFile(
        ApiEndpoints.guideProfile,
        formData: formData,
      );

      if (response.statusCode == 200) {
        final guideData = response.data['data']['guide'];
        final userData = response.data['data']['user'];
        
        // Update guide entity
        guide = GuideEntity(
          authId: userData['_id'] ?? '',
          fullName: userData['fullName'] ?? '',
          email: userData['email'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          bio: guideData['bio'] ?? '',
          languages: _parseLanguages(guideData['languages']),
          experience: guideData['experience'] ?? 0,
          profilePictureUrl: guideData['profilePicture'],
        );
        errorMessage = null;
      } else {
        errorMessage = 'Failed to update profile';
      }
    } catch (e) {
      errorMessage = 'Error: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
