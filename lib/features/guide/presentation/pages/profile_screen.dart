import 'package:flutter/material.dart';
import 'package:nepalexplorer/features/guide/data/models/guide_model.dart';
import '../../data/datasources/remote/guide_remote_datasource.dart';

class ProfileScreen extends StatefulWidget {
  final String token; // JWT token

  const ProfileScreen({super.key, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  GuideModel? guide;
  String? errorMessage;

  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController phoneController;
  late TextEditingController languagesController;
  late TextEditingController experienceController;

  final GuideRemoteDatasource api = GuideRemoteDatasource();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() => isLoading = true);

    try {
      guide = await api.getGuideProfile(widget.token);

      // initialize controllers
      nameController = TextEditingController(text: guide?.authId ?? "");
      bioController = TextEditingController(text: guide?.bio ?? "");
      phoneController = TextEditingController(text: guide?.authId ?? "");
      languagesController =
          TextEditingController(text: guide?.languages.join(", ") ?? "");
      experienceController =
          TextEditingController(text: guide?.experience.toString() ?? "0");

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  Future<void> saveProfile() async {
    if (guide == null) return;

    setState(() => isLoading = true);

    guide = GuideModel(
      guideId: guide!.guideId,
      authId: nameController.text,
      experience: int.tryParse(experienceController.text) ?? guide!.experience,
      languages: languagesController.text.split(",").map((e) => e.trim()).toList(),
      bio: bioController.text,
      isAvailable: guide!.isAvailable, fullName: '', email: '', phoneNumber: '',
    );

    try {
      final updatedGuide = await api.updateGuideProfile(widget.token, guide!);

      setState(() {
        guide = updatedGuide;
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Profile updated successfully")));
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text(errorMessage!));

    return Scaffold(
      appBar: AppBar(title: const Text("Guide Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),
            const SizedBox(height: 16),

            _textField("Name", nameController),
            _textField("Phone", phoneController),
            _textField("Languages", languagesController),
            _textField("Experience", experienceController),
            _textField("Bio", bioController, maxLines: 3),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
