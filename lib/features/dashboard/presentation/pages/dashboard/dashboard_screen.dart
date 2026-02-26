import 'package:flutter/material.dart';
import '../destination/destination_screen.dart';
import 'package:nepalexplorer/features/guide/presentation/pages/guides_list_screen.dart';
import 'notifications_screen.dart';
import '../favorites/favorites_screen.dart';
import '../destination/destination_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> destinations = const [
    {
      'title': 'Pashupatinath Temple',
      'location': 'Bagmati, Kathmandu',
      'rating': '4.7',
      'description': 'Sacred Hindu temple on the Bagmati River',
      'image': 'assets/images/pashupatinath.jpeg',
    },
    {
      'title': 'Chitwan National Park',
      'location': 'Bagmati, Chitwan',
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
      'description': 'Birthplace of Buddha and major pilgrimage destination',
      'image': 'assets/images/Lumbini.jpeg',
    },
  ];

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.terrain, 'label': 'Mountain'},
    {'icon': Icons.park, 'label': 'National\nPark'},
    {'icon': Icons.temple_hindu, 'label': 'Religious'},
    {'icon': Icons.directions_walk, 'label': 'Adventure'},
  ];

  final List<Map<String, dynamic>> activities = const [
    {'icon': Icons.landscape, 'label': 'Browse Destinations'},
    {'icon': Icons.person, 'label': 'Guide Details'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredDestinations() {
    if (_searchQuery.isEmpty) {
      return destinations;
    }

    return destinations
        .where((item) =>
            item['title'].toLowerCase().contains(_searchQuery) ||
            item['location'].toLowerCase().contains(_searchQuery) ||
            item['description'].toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDestinations = _filteredDestinations();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('NepalExplorer'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
              },
              child: const Icon(Icons.notifications_none),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hello Sandip!!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Welcome back! and explore the world...',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 39, 46, 44))),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Destination',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: const Icon(Icons.clear),
                      )
                    : const Icon(Icons.filter_list),
                filled: true,
                fillColor: const Color.fromARGB(255, 222, 218, 218),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categories',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        return CategoryItem(icon: item['icon'], label: item['label']);
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Best Destination',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('View all', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 16),
            filteredDestinations.isEmpty
                ? Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const Text(
                      'No destinations found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredDestinations.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 20),
                      itemBuilder: (context, index) {
                        final item = filteredDestinations[index];
                        return DestinationCard(
                          title: item['title'],
                          location: item['location'],
                          rating: item['rating'],
                          image: item['image'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DestinationDetailsScreen(
                                  destination: item,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActivityItem(
                        icon: activities[0]['icon'],
                        label: activities[0]['label'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DestinationScreen(),
                            ),
                          );
                        },
                      ),
                      ActivityItem(
                        icon: activities[1]['icon'],
                        label: activities[1]['label'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GuidesListScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ActivityItem(
                    icon: Icons.favorite,
                    label: 'My Favorites',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const CategoryItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade200, child: Icon(icon)),
        const SizedBox(height: 7),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title, location, rating, image;
  final VoidCallback onTap;
  const DestinationCard(
      {super.key,
      required this.title,
      required this.location,
      required this.rating,
      required this.image,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(image, height: 170, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(rating),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade200,
              child: Icon(widget.icon),
            ),
            const SizedBox(height: 8),
            Text(widget.label),
          ],
        ),
      ),
    );
  }
}
