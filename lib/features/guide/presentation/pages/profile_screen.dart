import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nepalexplorer/features/guide/presentation/view_model/profile_viewmodel.dart';
import 'package:nepalexplorer/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:nepalexplorer/core/api/api_endpoints.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  
  String? _profilePictureUrl;

  // Helper method to construct full image URL - uses proper emulator URL
  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    
    // If it already has http/https, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Use ApiEndpoints base URL and remove /api suffix
    final baseUrl = ApiEndpoints.baseUrl.replaceAll('/api', '');
    return '$baseUrl$imageUrl';
  }

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Will be handled in build method with Consumer
    });
  }

  Future<void> _selectProfilePicture() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      await _openCamera();
    } else if (status.isDenied) {
      bool allow = await _showPermissionDialog();
      if (allow) {
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Deny"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Allow"),
          ),
        ],
      ),
    ) ?? false;
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

  Future<void> _saveProfile(ProfileViewModel viewModel) async {
    if (_nameController.text.isEmpty) {
      _showErrorSnack('Name cannot be empty');
      return;
    }

    try {
      await viewModel.updateProfile(
        fullName: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        bio: _bioController.text,
        languages: _languagesController.text,
        experience: _experienceController.text,
        profilePictureUrl: _profileImage?.path,
      );

      if (viewModel.errorMessage == null) {
        setState(() {
          _profileImage = null;
          _profilePictureUrl = viewModel.guide?.profilePictureUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnack(viewModel.errorMessage ?? 'Failed to save profile');
      }
    } catch (e) {
      _showErrorSnack('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Guide Profile")),
      body: Consumer(
        builder: (context, ref, _) {
          final viewModel = ref.watch(profileViewModelProvider);

          // Fetch profile on first build
          if (viewModel.guide == null && !viewModel.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(profileViewModelProvider).fetchProfile('');
            });
          }

          if (viewModel.isLoading && viewModel.guide == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.guide == null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          // Populate controllers when guide data is loaded (first time only)
          if (viewModel.guide != null &&
              _nameController.text.isEmpty) {
            _nameController.text = viewModel.guide!.fullName;
            _emailController.text = viewModel.guide!.email;
            _phoneController.text = viewModel.guide!.phoneNumber;
            _bioController.text = viewModel.guide!.bio;
            _experienceController.text = viewModel.guide!.experience.toString();
            _languagesController.text = viewModel.guide!.languages.join(', ');
            _profilePictureUrl = viewModel.guide!.profilePictureUrl;
          }

          return SingleChildScrollView(
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
                  readOnly: true,
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
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Bio",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Years of Experience",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _languagesController,
                  decoration: const InputDecoration(
                    labelText: "Languages (comma separated)",
                    border: OutlineInputBorder(),
                    hintText: "e.g., English, Nepali, Hindi",
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
    _bioController.dispose();
    _experienceController.dispose();
    _languagesController.dispose();
    super.dispose();
  }
}
