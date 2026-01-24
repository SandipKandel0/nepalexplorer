class ApiEndpoints {
  ApiEndpoints._();

  // BASE URL
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String baseUrl = 'http://localhost:3000/api';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // AUTH
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static String authById(String id) => '$baseUrl/auth/$id';

  // USER
  static const String users = '$baseUrl/users';
  static String userById(String id) => '$baseUrl/users/$id';
  static String userProfile(String id) => '$baseUrl/users/$id/profile';

  static String checkEmailExists(String email) => '$baseUrl/users/email/$email';
  static String checkUsernameExists(String username) => '$baseUrl/users/username/$username';
  static String checkPhoneExists(String phone) => '$baseUrl/users/phone/$phone';

  // GUIDE
  static const String guideLogin = '$baseUrl/auth/loginGuide';  // Guide login
  static const String guideProfile = '$baseUrl/guides/profile'; // Guide profile
  static String guideById(String id) => '$baseUrl/guides/$id';
  static String guidesByDestination(String destId) =>
      '$baseUrl/guides/destination/$destId';

  // DESTINATION
  static const String destinations = '$baseUrl/destinations';
  static String destinationById(String id) => '$baseUrl/destinations/$id';
  static String destinationSearch(String query) =>
      '$baseUrl/destinations/search?query=$query';

  // PROFILE
  static const String profiles = '$baseUrl/profiles';
  static String profileById(String id) => '$baseUrl/profiles/$id';
  static String uploadProfilePic(String id) =>
      '$baseUrl/profiles/$id/upload-picture';
}
