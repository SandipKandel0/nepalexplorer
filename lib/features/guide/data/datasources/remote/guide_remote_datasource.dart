import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/guide_model.dart';

class GuideRemoteDatasource {
  final String baseUrl = 'http://localhost:3000/api'; // Your backend URL

  /// LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/auth/loginGuide');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data; // contains token + user data
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  /// GET GUIDE PROFILE
  Future<GuideModel> getGuideProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/guides/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return GuideModel.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? "Failed to fetch profile");
    }
  }

  /// UPDATE GUIDE PROFILE
  Future<GuideModel> updateGuideProfile(String token, GuideModel guide) async {
    final response = await http.put(
      Uri.parse('$baseUrl/guides/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(guide.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return GuideModel.fromJson(data['data']); // return updated guide
    } else {
      throw Exception(data['message'] ?? "Failed to update guide profile");
    }
  }
}
