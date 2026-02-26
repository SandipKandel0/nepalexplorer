import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/api/api_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ApiClient _apiClient;
  bool _loading = true;
  String? _error;
  List<dynamic> _requests = [];
  int _totalRequests = 0;
  int _pendingRequests = 0;
  int _acceptedRequests = 0;
  int _rejectedRequests = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get('/requests/guide');
      if (response.statusCode == 200) {
        final List<dynamic> requests = response.data['data'] ?? [];

        int pending = 0;
        int accepted = 0;
        int rejected = 0;

        for (final request in requests) {
          final status = (request['status'] ?? 'pending').toString().toLowerCase();
          if (status == 'accepted') {
            accepted++;
          } else if (status == 'rejected') {
            rejected++;
          } else {
            pending++;
          }
        }

        if (!mounted) return;
        setState(() {
          _requests = requests;
          _totalRequests = requests.length;
          _pendingRequests = pending;
          _acceptedRequests = accepted;
          _rejectedRequests = rejected;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load dashboard data';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentActivities = _requests.take(5).toList();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadDashboardStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardStats,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello Guide 👋',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Here is your request activity today',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: _showRequestNotifications,
                                icon: const Icon(Icons.notifications_none, size: 28),
                              ),
                              if (_pendingRequests > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _pendingRequests > 99
                                          ? '99+'
                                          : _pendingRequests.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (recentActivities.isEmpty)
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No recent request activity'),
                          ),
                        )
                      else
                        ...recentActivities.map(
                          (request) => _buildRecentActivityTile(request),
                        ),
                      const SizedBox(height: 22),
                      const Text(
                        'Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildTotalRequestsCard(),
                      const SizedBox(height: 16),
                      _buildActivityCard(),
                    ],
                  ),
                ),
    );
  }

  void _showRequestNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final notifications = _requests.take(10).toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (notifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No request notifications yet'),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final request = notifications[index];
                        final user = request['userName'] ?? 'A user';
                        final destination = request['destinationName'] ?? 'a destination';
                        final status = (request['status'] ?? 'pending').toString();

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.notifications),
                          title: Text('$user sent a request'),
                          subtitle: Text('$destination • ${status.toUpperCase()}'),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalRequestsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.list_alt, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Requests',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '$_totalRequests',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityTile(dynamic request) {
    final status = (request['status'] ?? 'pending').toString().toLowerCase();
    final destination = request['destinationName'] ?? 'Unknown destination';
    final user = request['userName'] ?? 'Unknown user';

    Color statusColor;
    if (status == 'accepted') {
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          child: Icon(Icons.schedule, color: statusColor, size: 18),
        ),
        title: Text(destination),
        subtitle: Text('Requested by $user'),
        trailing: Text(
          status.toUpperCase(),
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _buildActivityRow('Pending', _pendingRequests, Colors.orange),
            const SizedBox(height: 10),
            _buildActivityRow('Accepted', _acceptedRequests, Colors.green),
            const SizedBox(height: 10),
            _buildActivityRow('Rejected', _rejectedRequests, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
