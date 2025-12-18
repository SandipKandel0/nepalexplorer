import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false ,
        title: const Text('NepalExplorer'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello Sandip!!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome back and explore the world...',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Destination',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                filled: true,
                fillColor: Colors.grey.shade100,
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
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _CategoryItem(icon: Icons.terrain, label: 'Mountain'),
                        SizedBox(width: 16),
                        _CategoryItem(icon: Icons.park, label: 'National\nPark'),
                        SizedBox(width: 16),
                        _CategoryItem(icon: Icons.temple_hindu, label: 'Religious'),
                        SizedBox(width: 16),
                        _CategoryItem(icon: Icons.directions_walk, label: 'Adventure'),
                        SizedBox(width: 16),
                        _CategoryItem(icon: Icons.fastfood, label: 'Food'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Best Destination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'View all',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),

          
            SizedBox(
              height: 260,
              child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final destinations = [
                    {
                      'title': 'Pashupatinath Temple',
                      'location': 'Bagmati, Kathmandu',
                      'rating': '4.7',
                      'image':
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPMe5fuKSW0dIoVEtvO3qRd8mlqFbhMEZXJA&s',
                    },
                    {
                      'title': 'Chitwan National Park',
                      'location': 'Bagmati, Chitwan',
                      'rating': '4.6',
                      'image':
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPMe5fuKSW0dIoVEtvO3qRd8mlqFbhMEZXJA&s',
                    },
                    {
                      'title': 'Boudhanath Stupa',
                      'location': 'Kathmandu',
                      'rating': '4.8',
                      'image':
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPMe5fuKSW0dIoVEtvO3qRd8mlqFbhMEZXJA&s',
                    },
                    {
                      'title': 'Lumbini Garden',
                      'location': 'Lumbini',
                      'rating': '4.5',
                      'image':
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPMe5fuKSW0dIoVEtvO3qRd8mlqFbhMEZXJA&s',
                    },
                  ];

                  final item = destinations[index];

                  return DestinationCard(
                    title: item['title']!,
                    location: item['location']!,
                    rating: item['rating']!,
                    image: item['image']!,
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
                children: const [
                  Text(
                    'Our Activities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActivityItem(icon: Icons.map, label: 'Guide Details'),
                      _ActivityItem(icon: Icons.hotel, label: 'Available Hotel'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String title;
  final String location;
  final String rating;
  final String image;

  const DestinationCard({
    super.key,
    required this.title,
    required this.location,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              image,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(location,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActivityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
