import 'dart:convert';
import 'package:http/http.dart' as http;

class GuideRemoteDatasource {
  final String baseUrl = 'http://10.0.2.2:3000/api'; // Emulator URL

  // Login guide
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/auth/loginGuide');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? "Invalid credentials");
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // Get guide profile
  Future<Map<String, dynamic>> getGuideProfile(String token) async {
    final uri = Uri.parse('$baseUrl/guides/profile');
    final response = await http.get(
      uri,
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
}
