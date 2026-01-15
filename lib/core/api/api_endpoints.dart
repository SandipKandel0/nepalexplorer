class ApiEndpoints {
  ApiEndpoints._();

  // ==========================
  // BASE URL
  // ==========================
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
  // For iOS Simulator use: 'http://localhost:3000/api'
  // For physical device use your computer IP: 'http://192.168.x.x:3000/api'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==========================
  // AUTH TABLE ENDPOINTS
  // ==========================
  static const String auth = '/auth';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static String authById(String id) => '/auth/$id';

  // ==========================
  // USER TABLE ENDPOINTS
  // ==========================
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String userProfile(String id) => '/users/$id/profile';

  // ==========================
  // GUIDE TABLE ENDPOINTS
  // ==========================
  static const String guides = '/guides';
  static String guideById(String id) => '/guides/$id';
  static String guidesByDestination(String destinationId) => '/guides/destination/$destinationId';

  // ==========================
  // DESTINATION TABLE ENDPOINTS
  // ==========================
  static const String destinations = '/destinations';
  static String destinationById(String id) => '/destinations/$id';
  static String destinationSearch(String query) => '/destinations/search?query=$query';

  // ==========================
  // PROFILE TABLE ENDPOINTS
  // ==========================
  static const String profiles = '/profiles';
  static String profileById(String id) => '/profiles/$id';
  static String uploadProfilePic(String id) => '/profiles/$id/upload-picture';
}
