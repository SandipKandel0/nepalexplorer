import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  
  final List<Map<String, dynamic>> destinations = const [
    {
      'title': 'Pashupatinath Temple',
      'location': 'Bagmati, Kathmandu',
      'rating': '4.7',
      'image': 'assets/images/pashupatinath.jpg',
    },
    {
      'title': 'Chitwan National Park',
      'location': 'Bagmati, Chitwan',
      'rating': '4.6',
      'image': 'assets/images/chitwan.jpg',
    },
    {
      'title': 'Boudhanath Stupa',
      'location': 'Kathmandu',
      'rating': '4.8',
      'image': 'assets/images/BoudhhaStupa.jpg',
    },
    {
      'title': 'Lumbini Garden',
      'location': 'Lumbini',
      'rating': '4.5',
      'image': 'assets/images/Lumbini.jpg',
    },
  ];

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.terrain, 'label': 'Mountain'},
    {'icon': Icons.park, 'label': 'National\nPark'},
    {'icon': Icons.temple_hindu, 'label': 'Religious'},
    {'icon': Icons.directions_walk, 'label': 'Adventure'},
  ];

  final List<Map<String, dynamic>> activities = const [
    {'icon': Icons.map, 'label': 'Guide Details'},
    {'icon': Icons.hotel, 'label': 'Available Hotel'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('NepalExplorer'),
        actions: const [Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.notifications_none))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Hello Sandip!!',
          style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),

          const Text('Welcome back! and explore the world...',
          style: TextStyle(fontSize: 15, color:
          Color.fromARGB(255, 39, 46, 44))),

          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search Destination',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.filter_list),
              filled: true,
              fillColor: const Color.fromARGB(255, 222, 218, 218),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16)),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Categories',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index == categories.length - 1 ? 0 : 16),
                      child: CategoryItem(
                        icon: item['icon'], label: item['label']),
                    );
                  },
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
            Text('Best Destination',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold)),

            Text('View all',
            style: TextStyle(
            color: Colors.blue)),
          ]),

          const SizedBox(height: 16),
          
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: destinations.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = destinations[index];
                return DestinationCard(
                  title: item['title'],
                  location: item['location'],
                  rating: item['rating'],
                  image: item['image'],
                );
              },
            ),
          ),
          const SizedBox(height: 20),

        
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(16)),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: activities
                  .map((a) => ActivityItem(
                    icon: a['icon'], label: a['label']))
                  .toList(),
            ),
          ),
        ]),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Destination'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourite'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const CategoryItem({super.key,
  required this.icon,
  required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade200, child: Icon(icon)),
      const SizedBox(height: 7),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class DestinationCard extends StatelessWidget {
  final String title, location, rating, image;
  const DestinationCard({
    super.key,
      required this.title,
      required this.location,
      required this.rating,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        ClipRRect(borderRadius: BorderRadius.circular(16),
        child: Image.asset(image,
          height: 170,
          width: double.infinity, fit: BoxFit.cover)),
        const SizedBox(height: 8),

        Text(title, style: const TextStyle(
          fontWeight: FontWeight.bold),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),

        Text(location, style: const TextStyle(
          fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        
        Row(children:
        [const Icon(Icons.star, size: 14, color: Colors.orange),
        const SizedBox(width: 4), Text(rating)]),
      ]),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const ActivityItem({super.key,
    required this.icon,
    required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(radius: 26, backgroundColor: Colors.grey.shade200, child: Icon(icon)),
      const SizedBox(height: 8),
      Text(label),
    ]);
  }
}

