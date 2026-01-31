import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _role;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Dummy fetch, replace with your API call
  }

  void _fetchProfile() {
    // Example data
    _nameController.text = "John Doe";
    _emailController.text = "john@example.com";
    _phoneController.text = "1234567890";
    _role = "user";
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

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved (dummy)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.person, size: 60) : null,
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
                onPressed: _saveProfile,
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
