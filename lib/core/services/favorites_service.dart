import 'package:flutter/material.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  
  factory FavoritesService() {
    return _instance;
  }

  FavoritesService._internal();

  // Store favorites in memory (in a real app, use shared_preferences)
  final Set<String> _favorites = {};
  final List<Map<String, dynamic>> _favoriteDestinations = [];

  // Add a destination to favorites
  void addFavorite(Map<String, dynamic> destination) {
    final key = destination['title'] ?? '';
    if (!_favorites.contains(key)) {
      _favorites.add(key);
      _favoriteDestinations.add(destination);
      notifyListeners(); // Notify all listeners of the change
    }
  }

  // Remove a destination from favorites
  void removeFavorite(String destinationTitle) {
    _favorites.remove(destinationTitle);
    _favoriteDestinations.removeWhere((d) => d['title'] == destinationTitle);
    notifyListeners(); // Notify all listeners of the change
  }

  // Check if a destination is favorited
  bool isFavorite(String destinationTitle) {
    return _favorites.contains(destinationTitle);
  }

  // Get all favorite destinations
  List<Map<String, dynamic>> getFavorites() {
    return List.from(_favoriteDestinations);
  }

  // Get favorite count
  int getFavoriteCount() {
    return _favorites.length;
  }

  // Clear all favorites
  void clearFavorites() {
    _favorites.clear();
    _favoriteDestinations.clear();
    notifyListeners(); // Notify all listeners of the change
  }
}
