import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/guide_remote_datasource.dart';
import '../providers/guide_provider.dart';

class GuideViewModel extends ChangeNotifier {
  final Ref _ref;

  GuideViewModel(this._ref);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final api = _ref.read(guideRemoteDatasourceProvider);
      final response = await api.login(email, password);

      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['role'] == 'guide') {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = response['message'] ?? "Invalid credentials or not a guide";
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Something went wrong: ${e.toString()}";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Optional: fetch guide profile
  Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final api = _ref.read(guideRemoteDatasourceProvider);
      final profile = await api.getGuideProfile(token);
      return profile;
    } catch (e) {
      errorMessage = "Failed to fetch profile: ${e.toString()}";
      notifyListeners();
      return null;
    }
  }
}
