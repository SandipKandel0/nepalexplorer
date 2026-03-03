import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'guide_details_screen.dart';

class GuidesListScreen extends StatefulWidget {
  const GuidesListScreen({super.key});

  @override
  State<GuidesListScreen> createState() => _GuidesListScreenState();
}

class _GuidesListScreenState extends State<GuidesListScreen> {
  late ApiClient _apiClient;
  bool _loading = true;
  List<dynamic> _guides = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _fetchGuides();
  }

  Future<void> _fetchGuides() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get('/guides/list');
      
      if (response.statusCode == 200) {
        setState(() {
          _guides = response.data['data'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load guides';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Guides'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchGuides,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _guides.isEmpty
                  ? const Center(child: Text('No guides available'))
                  : RefreshIndicator(
                      onRefresh: _fetchGuides,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _guides.length,
                        itemBuilder: (context, index) {
                          final guide = _guides[index];
                          final user = guide['userId'] ?? {};
                          
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Profile Picture
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: guide['profilePicture'] != null
                                        ? Image.network(
                                            _getFullImageUrl(guide['profilePicture']),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.person, size: 60),
                                          )
                                        : const Icon(Icons.person, size: 60),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Name
                                        Text(
                                          user['fullName'] ?? 'Unknown',
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        // Experience
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.trending_up, size: 12),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${guide['experience'] ?? 0} yrs',
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        // Bio Preview
                                        Text(
                                          guide['bio'] ?? 'Tour guide',
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        // Book Button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => GuideDetailsScreen(
                                                    guide: guide,
                                                    user: user,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                              backgroundColor: Colors.blue,
                                            ),
                                            child: const Text(
                                              'Book',
                                              style: TextStyle(fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
