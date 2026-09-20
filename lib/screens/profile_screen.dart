import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../utils/translations.dart';
import '../widgets/aran_logo.dart';
import 'edit_profile_screen.dart';
import 'contacts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        StorageService.profileImagePath = image.path;
      });
    }
  }

  void _showImagePickerOptions() {
    final lang = StorageService.language;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFE91E63)),
              title: Text(Translations.get('camera', lang)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFE91E63)),
              title: Text(Translations.get('gallery', lang)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      appBar: AppBar(
        title: Text(Translations.get('profile', lang)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(lang),
            const SizedBox(height: 30),
            _buildMenu(lang),
            const SizedBox(height: 40),
            const AranLogo(size: 60),
            const SizedBox(height: 15),
            _buildAboutAran(lang),
            const SizedBox(height: 20),
            _buildPrivacyInfo(lang),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String lang) {
    String imagePath = StorageService.profileImagePath;
    return Column(
      children: [
        Stack(
          children: [
            Hero(
              tag: 'profile_pic',
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE91E63), width: 4),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: const Color(0xFFF8BBD0),
                  backgroundImage: imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
                  child: imagePath.isEmpty
                      ? const Icon(Icons.person, size: 75, color: Color(0xFFE91E63))
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 5,
              child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE91E63),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          StorageService.userName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
        ),
        const SizedBox(height: 4),
        Text(
          StorageService.userEmail, 
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16)
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
            if (result == true) setState(() {});
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(Translations.get('edit_profile', lang)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFE91E63),
            side: const BorderSide(color: Color(0xFFE91E63)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _ProfileTile(
            icon: Icons.people_alt_outlined,
            title: Translations.get('emergency_contacts', lang),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen())),
          ),
          const Divider(height: 1, indent: 60),
          _ProfileTile(
            icon: Icons.translate,
            title: Translations.get('language', lang),
            trailing: Text(
              lang == 'English' ? 'English' : 'தமிழ்',
              style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
            ),
            onTap: () {
              setState(() {
                StorageService.language = lang == 'English' ? 'Tamil' : 'English';
              });
            },
          ),
          const Divider(height: 1, indent: 60),
          _ProfileTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            onTap: () {
              StorageService.isLoggedIn = false;
              Navigator.pushReplacementNamed(context, '/login');
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAran(String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF8BBD0).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.get('about_aran', lang),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
          ),
          const SizedBox(height: 12),
          Text(
            Translations.get('about_desc', lang),
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.6),
          ),
          const SizedBox(height: 25),
          
          _buildInfoRow(Translations.get('created_by', lang), Translations.get('creator_name', lang)),
          const SizedBox(height: 15),
          _buildInfoRow(Translations.get('dept_label', lang), Translations.get('dept', lang), vertical: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool vertical = false}) {
    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54))),
      ],
    );
  }

  Widget _buildPrivacyInfo(String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF8BBD0).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.get('privacy', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
          ),
          const SizedBox(height: 12),
          Text(
            Translations.get('privacy_desc', lang),
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.8),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isLast;

  const _ProfileTile({required this.icon, required this.title, this.trailing, required this.onTap, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF8BBD0).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFFE91E63), size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
      shape: isLast ? const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))) : null,
    );
  }
}
