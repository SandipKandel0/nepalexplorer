import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';
import 'package:nepalexplorer/core/services/storage/user_session_service.dart';
import 'package:nepalexplorer/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:nepalexplorer/features/dashboard/presentation/view_model/user_profile_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  Uint8List? _profileImageBytes;
  String? _profileImageName;
  String? _profilePictureUrl;

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  Future<void> _selectProfilePicture() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      await _openCamera();
    } else if (status.isDenied) {
      final allow = await _showPermissionDialog();
      if (allow) {
        final result = await Permission.camera.request();
        if (result.isGranted) {
          await _openCamera();
        } else {
          _showErrorSnack('Camera permission denied');
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

    if (image == null) return;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
        _profileImageName = image.name;
        _profileImage = null;
      });
      return;
    }

    setState(() {
      _profileImage = File(image.path);
      _profileImageBytes = null;
      _profileImageName = image.name;
    });
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
              'This feature requires camera access to take a profile picture.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Deny'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Allow'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Camera permission is permanently denied. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
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

  Future<void> _saveProfile(UserProfileViewModel viewModel) async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnack('Name cannot be empty');
      return;
    }

    await viewModel.updateProfile(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      profilePicturePath: _profileImage?.path,
      profilePictureBytes: _profileImageBytes,
      profilePictureName: _profileImageName,
    );

    if (viewModel.errorMessage == null) {
      setState(() {
        _profileImage = null;
        _profileImageBytes = null;
        _profileImageName = null;
        _profilePictureUrl = viewModel.profile?.profilePictureUrl;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    _showErrorSnack(viewModel.errorMessage ?? 'Failed to update profile');
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    await ref.read(authViewModelProvider.notifier).logout();
    await UserSessionService().clearUserSession();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final viewModel = ref.watch(userProfileViewModelProvider);

          if (viewModel.profile == null && !viewModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(userProfileViewModelProvider).fetchProfile();
            });
          }
          if (viewModel.isLoading && viewModel.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null && viewModel.profile == null) {
            return Center(child: Text(viewModel.errorMessage!));
          }
          if (viewModel.profile != null && _nameController.text.isEmpty) {
            _nameController.text = viewModel.profile!.fullName;
            _emailController.text = viewModel.profile!.email;
            _phoneController.text = viewModel.profile!.phoneNumber;
            _profilePictureUrl = viewModel.profile!.profilePictureUrl;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageBytes != null
                          ? MemoryImage(_profileImageBytes!)
                          : _profileImage != null
                              ? FileImage(_profileImage!)
                              : _profilePictureUrl != null
                                  ? NetworkImage(_getFullImageUrl(_profilePictureUrl))
                                  : null,
                      child: (_profileImageBytes == null &&
                              _profileImage == null &&
                              _profilePictureUrl == null)
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _saveProfile(viewModel),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save Changes'),
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
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
