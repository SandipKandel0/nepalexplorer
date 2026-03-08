import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';

final userProfileViewModelProvider = ChangeNotifierProvider<UserProfileViewModel>(
  (ref) => UserProfileViewModel(),
);

class UserProfileData {
  final String authId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;

  const UserProfileData({
    required this.authId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
  });
}

class UserProfileViewModel extends ChangeNotifier {
  UserProfileViewModel({ApiClient? apiClient}) {
    _apiClient = apiClient ?? ApiClient();
  }

  late ApiClient _apiClient;

  bool isLoading = false;
  UserProfileData? profile;
  String? errorMessage;

  Future<void> fetchProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.getProfile);
      if (response.statusCode == 200) {
        profile = _parseProfile(response.data);
        errorMessage = null;
      } else {
        errorMessage = 'Failed to load profile';
        profile = null;
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ?? 'Failed to load profile')
          : 'Failed to load profile';
      errorMessage = message;
      profile = null;
    } catch (e) {
      errorMessage = 'Error: $e';
      profile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
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
      });

      if (profilePictureBytes != null && profilePictureBytes.isNotEmpty) {
        formData = FormData.fromMap({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'profilePicture': MultipartFile.fromBytes(
            profilePictureBytes,
            filename: profilePictureName ?? 'profile.jpg',
          ),
        });
      } else if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        formData = FormData.fromMap({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'profilePicture': await MultipartFile.fromFile(
            profilePicturePath,
            filename: profilePicturePath.split('/').last,
          ),
        });
      }

      final response = await _apiClient.uploadFile(
        ApiEndpoints.updateProfile,
        formData: formData,
      );

      if (response.statusCode == 200) {
        profile = _parseProfile(response.data);
        errorMessage = null;
      } else {
        errorMessage = 'Failed to update profile';
      }
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ?? 'Failed to update profile')
          : 'Failed to update profile';
      errorMessage = message;
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  UserProfileData _parseProfile(dynamic data) {
    final payload = (data is Map<String, dynamic>) ? data['data'] : null;
    final userData = (payload is Map<String, dynamic>) ? payload['user'] : null;

    if (userData is! Map<String, dynamic>) {
      throw Exception('Invalid profile response');
    }

    return UserProfileData(
      authId: userData['_id']?.toString() ?? '',
      fullName: userData['fullName']?.toString() ?? '',
      email: userData['email']?.toString() ?? '',
      phoneNumber: userData['phoneNumber']?.toString() ?? '',
      profilePictureUrl: userData['profilePicture']?.toString(),
    );
  }
}
