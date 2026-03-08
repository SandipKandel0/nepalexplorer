import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/services/favorites_service.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'destination_details_screen.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  late FavoritesService _favoritesService;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  StreamSubscription<int>? _proximitySub;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);
  int? _proximityValue;
  bool _isObjectNear = false;

  final List<Map<String, dynamic>> popularPlaces = const [
    {
      'title': 'Mount Everest',
      'location': 'Sagarmatha, Nepal',
      'rating': '4.9',
      'description': 'The highest mountain in the world',
      'image': 'assets/images/image1.png',
    },
    {
      'title': 'Pashupatinath Temple',
      'location': 'Bagmati, Kathmandu',
      'rating': '4.7',
      'description': 'Sacred Hindu temple on the Bagmati River',
      'image': 'assets/images/pashupatinath.jpeg',
    },
    {
      'title': 'Chitwan National Park',
      'location': 'Chitwan',
      'rating': '4.6',
      'description': 'Wildlife sanctuary and jungle adventure',
      'image': 'assets/images/chitwan.jpeg',
    },
    {
      'title': 'Boudhanath Stupa',
      'location': 'Kathmandu',
      'rating': '4.8',
      'description': 'Ancient Buddhist monument and pilgrimage site',
      'image': 'assets/images/BoudhhaStupa.jpeg',
    },
    {
      'title': 'Lumbini Garden',
      'location': 'Lumbini',
      'rating': '4.5',
      'description': 'Birthplace of Buddha',
      'image': 'assets/images/Lumbini.jpeg',
    },
    {
      'title': 'Pokhara Lake',
      'location': 'Pokhara',
      'rating': '4.7',
      'description': 'Beautiful lakeside city with Himalayan views',
      'image': 'assets/images/image1.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _favoritesService = FavoritesService();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _startShakeDetection();
    _startProximitySensor();
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    _proximitySub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startShakeDetection() {
    _accelerometerSub = accelerometerEventStream().listen((event) {
      final gX = event.x / 9.80665;
      final gY = event.y / 9.80665;
      final gZ = event.z / 9.80665;
      final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

      if (gForce > 2.7) {
        final now = DateTime.now();
        if (now.difference(_lastShakeAt) > const Duration(seconds: 2)) {
          _lastShakeAt = now;
          _refreshDestinations();
        }
      }
    });
  }

  void _startProximitySensor() {
    _proximitySub = ProximitySensor.events.listen(
      (eventValue) {
        if (!mounted) return;
        setState(() {
          _proximityValue = eventValue;
          _isObjectNear = eventValue > 0;
        });
      },
      onError: (_) {},
    );
  }

  void _refreshDestinations() {
    if (!mounted) return;
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshed destinations by shake'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredPlaces() {
    if (_searchQuery.isEmpty) {
      return popularPlaces;
    }
    return popularPlaces
        .where((place) =>
            place['title'].toLowerCase().contains(_searchQuery) ||
            place['location'].toLowerCase().contains(_searchQuery) ||
            place['description'].toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _getFilteredPlaces();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Popular Destinations'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_proximityValue != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    _isObjectNear ? Icons.sensors : Icons.sensors_off,
                    size: 16,
                    color: _isObjectNear ? Colors.teal : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isObjectNear
                        ? 'Proximity detected (near)'
                        : 'Proximity state: far',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isObjectNear ? Colors.teal : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredPlaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No destinations found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = filteredPlaces[index];
                      final isFavorite = _favoritesService.isFavorite(place['title']);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Image.asset(
                                    place['image'],
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isFavorite) {
                                          _favoritesService.removeFavorite(place['title']);
                                        } else {
                                          _favoritesService.addFavorite(place);
                                        }
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isFavorite
                                                ? 'Removed from favorites'
                                                : 'Added to favorites',
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Colors.red : Colors.grey,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        place['location'],
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    place['description'],
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(place['rating']),
                                        ],
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DestinationDetailsScreen(
                                                destination: place,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.info_outline, size: 18),
                                        label: const Text('Details'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

