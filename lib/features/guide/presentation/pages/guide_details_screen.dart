import 'package:flutter/material.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';

class GuideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> guide;
  final Map<String, dynamic> user;

  const GuideDetailsScreen({
    super.key,
    required this.guide,
    required this.user,
  });

  @override
  State<GuideDetailsScreen> createState() => _GuideDetailsScreenState();
}

class _GuideDetailsScreenState extends State<GuideDetailsScreen> {
  late ApiClient _apiClient;
  bool _submitting = false;

  // Form controllers
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> _submitRequest() async {
    if (_destinationController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _numberOfPeopleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final response = await _apiClient.post(
        '/requests/create',
        data: {
          'guideId': widget.guide['_id'],
          'destinationName': _destinationController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
          'numberOfPeople': int.parse(_numberOfPeopleController.text),
          'notes': _notesController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Failed to send request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = (widget.guide['languages'] as List<dynamic>?)?.join(', ') ?? 'Not specified';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['fullName'] ?? 'Guide'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guide Profile Card
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: widget.guide['profilePicture'] != null
                    ? NetworkImage(_getFullImageUrl(widget.guide['profilePicture']))
                    : null,
                child: widget.guide['profilePicture'] == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.user['fullName'] ?? 'Unknown',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.user['email'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Guide Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Experience', '${widget.guide['experience'] ?? 0} years'),
                    _buildInfoRow('Languages', languages),
                    _buildInfoRow('Phone', widget.user['phoneNumber'] ?? 'Not provided'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            if (widget.guide['bio'] != null && widget.guide['bio'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.guide['bio'] ?? ''),
                  const SizedBox(height: 24),
                ],
              ),

            // Booking Form
            const Text(
              'Send a Request',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination Name *',
                border: OutlineInputBorder(),
                hintText: 'e.g., Mount Everest',
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _selectDate(_startDateController),
              decoration: const InputDecoration(
                labelText: 'Start Date *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _endDateController,
              readOnly: true,
              onTap: () => _selectDate(_endDateController),
              decoration: const InputDecoration(
                labelText: 'End Date *',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _numberOfPeopleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of People *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
                hintText: 'Any special requests...',
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitRequest,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _numberOfPeopleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
