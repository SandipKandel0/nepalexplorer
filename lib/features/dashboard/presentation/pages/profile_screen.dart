import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nepalexplorer/core/api/api_client.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/features/auth/presentation/view_model/auth_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();
  late ApiClient _apiClient;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _role;
  String? _profilePictureUrl;

  bool _loading = false;

  // Helper method to construct full image URL
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // If it already has http/https, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Otherwise, prepend the server URL
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    try {
      final response = await _apiClient.get(ApiEndpoints.getProfile);
      
      if (response.statusCode == 200) {
        final data = response.data['data']['user'];
        setState(() {
          _nameController.text = data['fullName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _role = data['role'] ?? 'user';
          _profilePictureUrl = data['profilePicture'];
        });
      }
    } catch (e) {
      _showErrorSnack('Failed to load profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Show custom permission dialog
  Future<bool> _showPermissionDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Camera Permission Required"),
        content: const Text(
          "This feature requires access to your camera to take a profile picture.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Deny
            child: const Text("Deny"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Allow
            child: const Text("Allow"),
          ),
        ],
      ),
    ) ?? false;
  }

  // Request camera permission and open camera
  Future<void> _selectProfilePicture() async {
    // First check status
    var status = await Permission.camera.status;

    if (status.isGranted) {
      // Already granted → open camera
      await _openCamera();
    } else if (status.isDenied) {
      // Show custom dialog
      bool allow = await _showPermissionDialog();
      if (allow) {
        // Request permission
        final result = await Permission.camera.request();
        if (result.isGranted) {
          await _openCamera();
        } else {
          _showDeniedSnack();
        }
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _showDeniedSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Camera permission denied")),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Camera permission is permanently denied. Please enable it in settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await ref.read(authViewModelProvider.notifier).logout();
      
      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showErrorSnack('Name cannot be empty');
      return;
    }

    setState(() => _loading = true);
    try {
      FormData formData = FormData.fromMap({
        'fullName': _nameController.text,
        'phoneNumber': _phoneController.text,
      });

      // Add profile picture if selected
      if (_profileImage != null) {
        formData = FormData.fromMap({
          'fullName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'profilePicture': await MultipartFile.fromFile(
            _profileImage!.path,
            filename: _profileImage!.path.split('/').last,
          ),
        });
      }

      final response = await _apiClient.uploadFile(
        ApiEndpoints.updateProfile,
        formData: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['user'];
        setState(() {
          _profilePictureUrl = data['profilePicture'];
          _profileImage = null; // Clear local image after upload
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnack('Failed to save profile: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: _loading && _profilePictureUrl == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _profilePictureUrl != null
                                ? NetworkImage(_getFullImageUrl(_profilePictureUrl))
                                : null,
                        child: (_profileImage == null && _profilePictureUrl == null)
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _selectProfilePicture,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Role",
                      border: const OutlineInputBorder(),
                      hintText: _role ?? '',
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveProfile,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Save Changes"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
