import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;
  static const String _ipAddress = "192.168.1.1";
  static const int _port = 3000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) {
      return _ipAddress;
    }
    if (kIsWeb || Platform.isIOS) {
      return "localhost";
    }
    if (Platform.isAndroid) {
      return "10.0.2.2";
    }
    return "localhost";
  }

  static String get serverUrl => "http://$_host:$_port/api";
  static String get baseUrl => "$serverUrl";
  static String get mediaServerUrl => serverUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // AUTH
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static String authById(String id) => '/auth/$id';

  // USER
  static const String users = '/users';
  static String userById(String id) => '$baseUrl/users/$id';
  static String userProfile(String id) => '$baseUrl/users/$id/profile';

  static String checkEmailExists(String email) => '$baseUrl/users/email/$email';
  static String checkUsernameExists(String username) => '$baseUrl/users/username/$username';
  static String checkPhoneExists(String phone) => '$baseUrl/users/phone/$phone';

  // GUIDE
  static const String guideLogin = '/auth/loginGuide';  // Guide login
  static const String guideProfile = '/guides/profile'; // Guide profile
  static String guideById(String id) => '$baseUrl/guides/$id';
  static String guidesByDestination(String destId) =>
      '$baseUrl/guides/destination/$destId';

  // DESTINATION
  static const String destinations = '/destinations';
  static String destinationById(String id) => '$baseUrl/destinations/$id';
  static String destinationSearch(String query) =>
      '$baseUrl/destinations/search?query=$query';

  // PROFILE
  static const String profiles = '/profiles';
  static String profileById(String id) => '$baseUrl/profiles/$id';
  static String uploadProfilePic(String id) =>
      '$baseUrl/profiles/$id/upload-picture';
}
