import 'package:flutter/material.dart';
import '../services/call_service.dart';
import '../services/storage_service.dart';
import '../utils/translations.dart';

class EmergencyServicesScreen extends StatelessWidget {
  const EmergencyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;

    final List<Map<String, dynamic>> services = [
      {'name': Translations.get('emergency_112', lang), 'number': '112', 'icon': Icons.emergency, 'color': Colors.red.shade900},
      {'name': Translations.get('police', lang), 'number': '100', 'icon': Icons.local_police, 'color': Colors.blue.shade800},
      {'name': Translations.get('child_helpline', lang), 'number': '1098', 'icon': Icons.child_care, 'color': Colors.orange.shade900},
      {'name': Translations.get('ambulance', lang), 'number': '102', 'icon': Icons.medical_services, 'color': Colors.red.shade700},
      {'name': Translations.get('women_helpline', lang), 'number': '181', 'icon': Icons.woman, 'color': const Color(0xFFE91E63)},
      {'name': Translations.get('fire_rescue', lang), 'number': '101', 'icon': Icons.fire_truck, 'color': Colors.orange.shade800},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get('emergency_services', lang)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (service['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 30),
              ),
              title: Text(
                service['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                service['number'] as String,
                style: TextStyle(color: service['color'] as Color, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                onPressed: () => CallService.makeCall(service['number'] as String),
                icon: const Icon(Icons.call, color: Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}
