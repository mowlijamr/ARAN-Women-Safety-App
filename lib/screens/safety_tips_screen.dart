import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/translations.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get('safety_instructions', lang)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(Translations.get('how_to_use', lang), Icons.menu_book),
          _buildInstructionCard(
            "SOS + SIREN",
            "Tap the large button. A 3-second countdown starts. After completion, a loud siren starts and the flashlight flickers. Emergency contacts are alerted.",
            Icons.notifications_active,
          ),
          _buildInstructionCard(
            "SILENT SOS",
            "Use when you need to stay quiet. No countdown, no sound, no light. Immediately gets your location and alerts contacts.",
            Icons.notifications_off,
          ),
          _buildInstructionCard(
            "Shake Detection",
            "Shake your phone twice intentionally to trigger SOS + SIREN. Useful if you can't reach the button.",
            Icons.vibration,
          ),
          _buildInstructionCard(
            "Capture Evidence",
            "Quickly open the camera to take photos or videos of an incident. Evidence is saved locally.",
            Icons.camera_alt,
          ),
          const SizedBox(height: 30),
          
          _buildSectionHeader("Women's Safety Advice", Icons.favorite),
          _buildAdviceCard(
            "Harassment is NOT your fault",
            "Do not feel ashamed. Move to a safe public place immediately and tell someone you trust.",
            const Color(0xFFE91E63),
          ),
          _buildAdviceCard(
            "Trust Your Instincts",
            "If you feel unsafe, you probably are. Don't wait for proof. Act immediately.",
            const Color(0xFF880E4F),
          ),
          
          const SizedBox(height: 30),
          _buildSectionHeader("Personal Safety Tips", Icons.security),
          _buildTipItem("Stay aware of your surroundings at all times."),
          _buildTipItem("Keep your phone charged and easily accessible."),
          _buildTipItem("Share your real-time location with a trusted person when traveling alone."),
          _buildTipItem("Identify safe zones (police stations, hospitals) on your usual routes."),
          
          const SizedBox(height: 30),
          _buildSectionHeader("Common Emergency Steps", Icons.emergency),
          _buildStepItem(1, "Stay as calm as possible."),
          _buildStepItem(2, "Move away from immediate danger."),
          _buildStepItem(3, "Trigger ARAN SOS."),
          _buildStepItem(4, "Seek help from nearby people."),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE91E63), size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(String title, String desc, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF8BBD0), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFFE91E63), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 5),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFFE91E63), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFE91E63),
            child: Text("$step", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
