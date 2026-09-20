import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/translations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = StorageService.userName;
    _emailController.text = StorageService.userEmail;
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) return;
    StorageService.userName = _nameController.text.trim();
    StorageService.userEmail = _emailController.text.trim();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get('edit_profile', lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: Translations.get('name', lang),
                filled: true,
                fillColor: const Color(0xFFF8BBD0).withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFE91E63)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: Translations.get('email', lang),
                filled: true,
                fillColor: const Color(0xFFF8BBD0).withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFE91E63)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: Text(Translations.get('save', lang).toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
