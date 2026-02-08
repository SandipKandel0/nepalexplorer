import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/api/api_client.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late ApiClient _apiClient;
  bool _loading = true;
  List<dynamic> _requests = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get('/requests/guide');
      
      if (response.statusCode == 200) {
        setState(() {
          _requests = response.data['data'] ?? [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load requests';
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

  Future<void> _updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      final response = await _apiClient.post(
        '/requests/$requestId/status',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $status successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchRequests();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
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
                        onPressed: _fetchRequests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _requests.isEmpty
                  ? const Center(child: Text('No requests yet'))
                  : RefreshIndicator(
                      onRefresh: _fetchRequests,
                      child: ListView.builder(
                        itemCount: _requests.length,
                        itemBuilder: (context, index) {
                          final request = _requests[index];
                          final status = request['status'] ?? 'pending';

                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ExpansionTile(
                              title: Text(request['userName'] ?? 'Unknown User'),
                              subtitle: Text(
                                request['destinationName'] ?? 'No destination',
                              ),
                              trailing: Chip(
                                label: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(status),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildRequestRow(
                                        'Email',
                                        request['userEmail'] ?? 'N/A',
                                      ),
                                      _buildRequestRow(
                                        'Destination',
                                        request['destinationName'] ?? 'N/A',
                                      ),
                                      _buildRequestRow(
                                        'Dates',
                                        '${request['startDate']} to ${request['endDate']}',
                                      ),
                                      _buildRequestRow(
                                        'People',
                                        '${request['numberOfPeople']} person(s)',
                                      ),
                                      if (request['notes'] != null &&
                                          request['notes'].toString().isNotEmpty)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Notes:',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(request['notes']),
                                          ],
                                        ),
                                      const SizedBox(height: 16),
                                      if (status == 'pending')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _updateRequestStatus(
                                                  request['_id'],
                                                  'accepted',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: const Text('Accept'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _updateRequestStatus(
                                                  request['_id'],
                                                  'rejected',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Reject'),
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
    );
  }

  Widget _buildRequestRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

