import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/api/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late ApiClient _apiClient;
  bool _loading = true;
  List<dynamic> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get('/notifications');

      if (response.statusCode == 200) {
        setState(() {
          _notifications = response.data['data'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications';
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

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _apiClient.post('/notifications/$notificationId/read');
      _fetchNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiClient.post('/notifications/read-all');
      _fetchNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty && _notifications.any((n) => !n['read']))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
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
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications yet'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          final isRead = notification['read'] ?? false;

                          return Dismissible(
                            key: Key(notification['_id']),
                            background: Container(
                              color: Colors.grey[300],
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete),
                            ),
                            child: Container(
                              color: isRead ? Colors.white : Colors.blue.shade50,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getTypeColor(notification['type']),
                                  child: Icon(
                                    _getTypeIcon(notification['type']),
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  notification['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      notification['message'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(notification['createdAt']),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: !isRead
                                    ? GestureDetector(
                                        onTap: () => _markAsRead(notification['_id']),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  if (!isRead) {
                                    _markAsRead(notification['_id']);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
