import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../services/shake_service.dart';
import '../services/siren_service.dart';
import '../services/flashlight_service.dart';
import '../services/location_service.dart';
import '../services/sms_service.dart';
import '../utils/translations.dart';
import '../models/emergency_contact.dart';

class EmergencySessionScreen extends StatefulWidget {
  const EmergencySessionScreen({super.key});

  @override
  State<EmergencySessionScreen> createState() => _EmergencySessionScreenState();
}

class _EmergencySessionScreenState extends State<EmergencySessionScreen> {
  LocationResult _locationResult = LocationResult(status: LocationStatus.initial);
  List<EmergencyContact> _contacts = [];
  bool _showSmsPopup = false;
  String _emergencyMessage = "";

  @override
  void initState() {
    super.initState();
    _contacts = StorageService.getContacts();
    _initEmergencyActions();
  }

  void _initEmergencyActions() async {
    // Start getting location
    _getLocation();

    // Show SMS popup after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && StorageService.isSOSActive) {
        setState(() {
          _showSmsPopup = true;
        });
      }
    });
  }

  Future<void> _getLocation() async {
    setState(() {
      _locationResult = LocationResult(status: LocationStatus.loading);
    });

    final result = await LocationService.getCurrentLocation();
    
    if (mounted) {
      setState(() {
        _locationResult = result;
        _emergencyMessage = SMSService.generateEmergencyMessage(
          result.position?.latitude, 
          result.position?.longitude
        );
      });
    }
  }

  void _callContact(EmergencyContact contact) async {
    final Uri url = Uri.parse('tel:${contact.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      List<String> calledIds = List.from(StorageService.calledContactIds);
      if (!calledIds.contains(contact.id)) {
        calledIds.add(contact.id);
        StorageService.calledContactIds = calledIds;
        if (mounted) setState(() {});
      }
    }
  }

  void _sendSmsToAll() async {
    setState(() => _showSmsPopup = false);
    
    if (_contacts.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sending SMS to emergency contacts...")),
    );

    for (var contact in _contacts) {
      if (contact.phoneNumber == '100' || contact.phoneNumber == '181') continue;
      await SMSService.sendEmergencySMS(contact.phoneNumber, _emergencyMessage);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Emergency SMS sent successfully.")),
      );
    }
  }

  void _stopEmergency() {
    final lang = StorageService.language;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.get('cancel_emergency', lang)),
        content: const Text("Are you sure you want to end this emergency session? This will stop all alerts."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () {
              SirenService.stopSiren();
              FlashlightService.stopBlinking();
              ShakeService.resetTrigger();
              StorageService.clearSOSSession();
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("END SESSION"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    final bool isSirenMode = StorageService.sosMode == 'SIREN';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF1F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF880E4F),
          foregroundColor: Colors.white,
          title: const Text("EMERGENCY SESSION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.close), onPressed: _stopEmergency),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildStatusHeader(lang, isSirenMode),
                _buildLocationCard(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Emergency Contacts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF880E4F))),
                  ),
                ),
                Expanded(child: _buildContactsList(lang)),
                _buildCancelButton(lang),
              ],
            ),
            if (_showSmsPopup) _buildSmsNotification(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String lang, bool isSirenMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF880E4F),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.get('emergency_activated', lang),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  isSirenMode ? "SIREN + FLASHLIGHT ACTIVE" : "SILENT SOS ACTIVE",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF8BBD0), borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    _locationResult.status == LocationStatus.success ? Icons.location_on : Icons.location_searching,
                    color: const Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationResult.status == LocationStatus.success ? "Exact Location Secured" : "Locating...",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (_locationResult.status == LocationStatus.success)
                        Text(
                          "Accuracy: ±${_locationResult.position!.accuracy.toStringAsFixed(1)}m",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      else if (_locationResult.message != null)
                        Text(
                          _locationResult.message!,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                if (_locationResult.status == LocationStatus.loading)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            if (_locationResult.status == LocationStatus.success) ...[
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse(LocationService.getGoogleMapsUrl(_locationResult.position!.latitude, _locationResult.position!.longitude)), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.map),
                label: const Text("VIEW ON MAP"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: const Color(0xFF880E4F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (_locationResult.status != LocationStatus.loading)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(onPressed: _getLocation, child: const Text("RETRY LOCATION")),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(String lang) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final bool isCalled = StorageService.calledContactIds.contains(contact.id);
        final bool isService = contact.phoneNumber == '100' || contact.phoneNumber == '181';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: CircleAvatar(
              backgroundColor: isService ? Colors.red : const Color(0xFFE91E63),
              child: Icon(isService ? Icons.emergency : Icons.person, color: Colors.white, size: 20),
            ),
            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(isCalled ? Translations.get('called', lang) : contact.phoneNumber, 
                          style: TextStyle(color: isCalled ? Colors.green : Colors.grey)),
            trailing: CircleAvatar(
              backgroundColor: const Color(0xFFF8BBD0),
              child: IconButton(
                icon: const Icon(Icons.call, color: Color(0xFFE91E63), size: 20),
                onPressed: () => _callContact(contact),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(String lang) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: OutlinedButton(
        onPressed: _stopEmergency,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
          side: const BorderSide(color: Color(0xFF880E4F), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          Translations.get('cancel_emergency', lang).toUpperCase(),
          style: const TextStyle(color: Color(0xFF880E4F), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSmsNotification(String lang) {
    return Positioned(
      top: 10,
      left: 15,
      right: 15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: const Color(0xFFE91E63), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFFE91E63), child: Icon(Icons.sms, color: Colors.white)),
              title: const Text("Emergency SMS Ready", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Tap to send your location to all contacts."),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showSmsPopup = false)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: ElevatedButton(
                onPressed: _sendSmsToAll,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("SEND SMS NOW", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
