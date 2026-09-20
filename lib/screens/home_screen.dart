import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import '../services/storage_service.dart';
import '../utils/translations.dart';
import '../widgets/aran_logo.dart';
import '../main.dart'; // To access mainNavKey
import 'emergency_services_screen.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';
import 'safety_tips_screen.dart';
import 'nearby_safety_screen.dart';
import 'fake_call_screen.dart';
import 'quick_safety_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleEvidenceCapture() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Capture Evidence", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Captured files will be saved to your phone's gallery.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: _CaptureOption(
                    icon: Icons.camera_alt,
                    label: "PHOTO",
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(context);
                      _capture(ImageSource.camera, isVideo: false);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _CaptureOption(
                    icon: Icons.videocam,
                    label: "VIDEO",
                    color: const Color(0xFF880E4F),
                    onTap: () {
                      Navigator.pop(context);
                      _capture(ImageSource.camera, isVideo: true);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _capture(ImageSource source, {required bool isVideo}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source);
      } else {
        file = await _picker.pickImage(source: source);
      }

      if (file != null) {
        if (!isVideo) {
          await Gal.putImage(file.path);
        } else {
          await Gal.putVideo(file.path);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Evidence saved to Gallery successfully.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save evidence. Check permissions.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    String imagePath = StorageService.profileImagePath;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(lang, imagePath),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildWelcomeText(lang),
                    const SizedBox(height: 25),
                    _buildMainEmergencyActions(lang),
                    const SizedBox(height: 30),
                    _buildSectionTitle(Translations.get('safety', lang)),
                    const SizedBox(height: 15),
                    _buildFeatureGrid(lang),
                    const SizedBox(height: 25),
                    _buildChatbotBanner(lang),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String lang, String imagePath) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          const AranLogo(size: 40),
          const SizedBox(width: 12),
          const Text(
            'ARAN | அரண்',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
          ),
          const Spacer(),
          _buildLanguageToggle(lang),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())).then((_) => setState(() {})),
            child: Hero(
              tag: 'profile_pic',
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF8BBD0),
                backgroundImage: imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
                child: imagePath.isEmpty ? const Icon(Icons.person, color: Color(0xFFE91E63), size: 22) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(String lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('danger_question', lang),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D)),
        ),
        const SizedBox(height: 4),
        Text(
          Translations.get('help_tap', lang),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMainEmergencyActions(String lang) {
    return Column(
      children: [
        _SOSLargeButton(
          title: Translations.get('sos_siren', lang),
          subtitle: Translations.get('sos_siren_subtitle', lang),
          icon: Icons.notifications_active,
          color: const Color(0xFFE91E63),
          onTap: () => mainNavKey.currentState?.triggerSOS(mode: 'SIREN'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _SOSMediumButton(
                title: Translations.get('silent_sos', lang),
                icon: Icons.notifications_off,
                color: const Color(0xFF880E4F),
                onTap: () => mainNavKey.currentState?.triggerSOS(mode: 'SILENT'),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _SOSMediumButton(
                title: "Shake to SOS",
                icon: Icons.vibration,
                color: const Color(0xFF2D2D2D),
                onTap: () {}, 
                isInfoOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
    );
  }

  Widget _buildFeatureGrid(String lang) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _FeatureCard(
          title: Translations.get('emergency_contacts', lang),
          icon: Icons.people_outline,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen())),
        ),
        _FeatureCard(
          title: Translations.get('my_location', lang),
          icon: Icons.my_location,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbySafetyScreen())),
        ),
        _FeatureCard(
          title: "Capture Evidence",
          icon: Icons.camera_alt_outlined,
          onTap: _handleEvidenceCapture,
        ),
        _FeatureCard(
          title: "Fake Call",
          icon: Icons.phone_callback_outlined,
          onTap: () => _showFakeCallContactPicker(),
        ),
        _FeatureCard(
          title: Translations.get('safety_instructions', lang),
          icon: Icons.menu_book_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SafetyTipsScreen())),
        ),
        _FeatureCard(
          title: Translations.get('emergency_services', lang),
          icon: Icons.local_police_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyServicesScreen())),
        ),
      ],
    );
  }

  Widget _buildChatbotBanner(String lang) {
    final isTamil = lang == 'Tamil';
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuickSafetyGuideScreen())),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF880E4F), Color(0xFFE91E63)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white24,
              child: Icon(Icons.menu_book, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? "பாதுகாப்பு வழிகாட்டி" : "Quick Safety Guide", 
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTamil ? "உடனடி ஆஃப்லைன் வழிகாட்டலைப் பெறுங்கள்" : "Get immediate offline safety advice", 
                    style: const TextStyle(color: Colors.white70, fontSize: 13)
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showFakeCallContactPicker() {
    final contacts = StorageService.getContacts();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Fake Call Setup", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFFE91E63)),
                  title: Text(contacts[index].name),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FakeCallScreen(contact: contacts[index])));
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text("Unknown Caller"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FakeCallScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(String lang) {
    return GestureDetector(
      onTap: () {
        setState(() {
          StorageService.language = lang == 'English' ? 'Tamil' : 'English';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF8BBD0).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE91E63), width: 1),
        ),
        child: Text(
          lang == 'English' ? 'தமிழ்' : 'EN',
          style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CaptureOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _SOSLargeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SOSLargeButton({required this.title, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(25),
      elevation: 8,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SOSMediumButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isInfoOnly;

  const _SOSMediumButton({required this.title, required this.icon, required this.color, required this.onTap, this.isInfoOnly = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(25),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.3),
      child: InkWell(
        onTap: isInfoOnly ? null : onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF8BBD0).withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFE91E63), size: 30),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D2D2D)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
