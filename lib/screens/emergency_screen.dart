import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/call_service.dart';
import '../utils/translations.dart';
import 'contacts_screen.dart';
import 'emergency_services_screen.dart';

import 'quick_safety_guide_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get('emergency', lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSafetyGuideButton(context, lang),
            const SizedBox(height: 30),
            _buildSectionHeader(context, Translations.get('emergency_services', lang), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyServicesScreen()));
            }),
            const SizedBox(height: 15),
            _buildEmergencyServiceGrid(context, lang),
            const SizedBox(height: 40),
            _buildSectionHeader(context, Translations.get('emergency_contacts', lang), () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen()));
            }),
            const SizedBox(height: 15),
            _buildContactsList(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyGuideButton(BuildContext context, String lang) {
    final isTamil = lang == 'Tamil';
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuickSafetyGuideScreen())),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF880E4F), Theme.of(context).primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.menu_book, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? "பாதுகாப்பு வழிகாட்டி" : "Quick Safety Guide",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isTamil ? "உடனடி பாதுகாப்பு வழிகாட்டலைப் பெறுங்கள்" : "Get immediate offline safety guidance",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text('View All', style: TextStyle(color: Color(0xFFE91E63))),
        ),
      ],
    );
  }

  Widget _buildEmergencyServiceGrid(BuildContext context, String lang) {
    final List<Map<String, dynamic>> services = [
      {'name': Translations.get('emergency_112', lang), 'number': '112', 'icon': Icons.emergency, 'color': Colors.red.shade900},
      {'name': Translations.get('police', lang), 'number': '100', 'icon': Icons.local_police, 'color': Colors.blue.shade800},
      {'name': Translations.get('child_helpline', lang), 'number': '1098', 'icon': Icons.child_care, 'color': Colors.orange.shade900},
      {'name': Translations.get('ambulance', lang), 'number': '102', 'icon': Icons.medical_services, 'color': Colors.red.shade700},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return InkWell(
          onTap: () => CallService.makeCall(service['number'] as String),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(service['icon'] as IconData, color: service['color'] as Color, size: 28),
                const SizedBox(height: 8),
                Text(
                  service['name'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  service['number'] as String,
                  style: TextStyle(color: service['color'] as Color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactsList(BuildContext context, String lang) {
    final contacts = StorageService.getContacts();

    if (contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF8BBD0)),
        ),
        child: Column(
          children: [
            Icon(Icons.people_outline, color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 10),
            Text(Translations.get('no_contacts', lang), style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen())),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
              child: Text(Translations.get('add_contact', lang)),
            )
          ],
        ),
      );
    }

    return Column(
      children: contacts.take(3).map((contact) => Card(
        margin: const EdgeInsets.only(bottom: 15),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFF8BBD0),
            child: Icon(Icons.person, color: Color(0xFFE91E63)),
          ),
          title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(contact.phoneNumber),
          trailing: IconButton(
            icon: const Icon(Icons.call, color: Colors.green),
            onPressed: () => CallService.makeCall(contact.phoneNumber),
          ),
        ),
      )).toList(),
    );
  }
}
