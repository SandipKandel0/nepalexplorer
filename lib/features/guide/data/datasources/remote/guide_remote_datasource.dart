import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nepalexplorer/features/guide/data/models/guide_model.dart';

class GuideRemoteDatasource {
  final String baseUrl = 'http://localhost:3000/api'; // Emulator URL

 Future<Map<String, dynamic>> login(String email, String password) async {
  final uri = Uri.parse('http://localhost:3000/api/auth/loginGuide');


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


  // Get guide profile
  Future<Map<String, dynamic>> getGuideProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/guides/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? "Failed to fetch profile");
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
  
  /// UPDATE Guide Profile
  Future<void> updateGuideProfile(GuideModel guide) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${guide.authId}", // token stored as authId
      },
      body: jsonEncode(guide.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update guide profile");
    }
  }
}

