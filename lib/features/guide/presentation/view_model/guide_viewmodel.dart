import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepalexplorer/features/guide/data/models/guide_model.dart';
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

      final token = response['token'];

      isLoading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = response['message'] ?? "Invalid credentials";
      isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    errorMessage = e.toString();
    isLoading = false;
    notifyListeners();
    return false;
  }
}
  // Optional: fetch guide profile
  Future<GuideModel?> getProfile(String token) async {
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
