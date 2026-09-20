import 'package:flutter/material.dart';
import '../models/safety_situation.dart';
import '../utils/quick_safety_data.dart';
import '../services/storage_service.dart';
import 'emergency_session_screen.dart';
import 'nearby_safety_screen.dart';
import 'contacts_screen.dart';
import 'emergency_services_screen.dart';
import 'fake_call_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

class QuickSafetyGuideScreen extends StatefulWidget {
  const QuickSafetyGuideScreen({super.key});

  @override
  State<QuickSafetyGuideScreen> createState() => _QuickSafetyGuideScreenState();
}

class _QuickSafetyGuideScreenState extends State<QuickSafetyGuideScreen> {
  SafetySituation? _selectedSituation;
  final ImagePicker _picker = ImagePicker();

  void _onSituationSelected(SafetySituation situation) {
    setState(() {
      _selectedSituation = situation;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedSituation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    final isTamil = lang == 'Tamil';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      appBar: AppBar(
        title: Text(isTamil ? "பாதுகாப்பு வழிகாட்டி" : "Quick Safety Guide"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE91E63)),
          onPressed: _selectedSituation == null 
              ? () => Navigator.pop(context) 
              : _resetSelection,
        ),
        actions: [
          _buildLanguageToggle(),
        ],
      ),
      body: _selectedSituation == null 
          ? _buildSituationList(isTamil) 
          : _buildSituationDetail(isTamil),
    );
  }

  Widget _buildLanguageToggle() {
    final lang = StorageService.language;
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: ActionChip(
        label: Text(lang == 'English' ? "தமிழ்" : "EN"),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        backgroundColor: const Color(0xFFE91E63),
        onPressed: () {
          setState(() {
            StorageService.language = lang == 'English' ? 'Tamil' : 'English';
          });
        },
      ),
    );
  }

  Widget _buildSituationList(bool isTamil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTamil ? "இப்போது உங்களுக்கு என்ன நடக்கிறது?" : "Select what you are experiencing",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 5),
              Text(
                isTamil ? "உடனடி பாதுகாப்பு வழிகாட்டுதலைப் பெற ஒரு சூழலைத் தேர்ந்தெடுக்கவும்" : "Choose your situation to get immediate safety guidance.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: QuickSafetyData.situations.length,
            itemBuilder: (context, index) {
              final situation = QuickSafetyData.situations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8BBD0).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(situation.icon, color: const Color(0xFFE91E63)),
                  ),
                  title: Text(
                    isTamil ? situation.titleTamil : situation.titleEnglish,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () => _onSituationSelected(situation),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSituationDetail(bool isTamil) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Icon(_selectedSituation!.icon, color: const Color(0xFFE91E63), size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    isTamil ? _selectedSituation!.titleTamil : _selectedSituation!.titleEnglish,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "SAFETY ADVICE",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF880E4F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isTamil ? _selectedSituation!.responseTamil : _selectedSituation!.responseEnglish,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "RECOMMENDED ACTIONS",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),
          ..._selectedSituation!.recommendedFeatures.map((feature) => _buildFeatureButton(feature, isTamil)),
          const SizedBox(height: 30),
          Center(
            child: OutlinedButton(
              onPressed: _resetSelection,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE91E63)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(isTamil ? "பின் செல்" : "GO BACK", style: const TextStyle(color: Color(0xFFE91E63))),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(ARANFeature feature, bool isTamil) {
    String label;
    IconData icon;
    VoidCallback onTap;

    switch (feature) {
      case ARANFeature.sos:
        label = isTamil ? "SOS + சைரன்" : "SOS + SIREN";
        icon = Icons.notifications_active;
        onTap = () => _triggerSOS('SIREN');
        break;
      case ARANFeature.silentSos:
        label = isTamil ? "சத்தமில்லா SOS" : "SILENT SOS";
        icon = Icons.notifications_off;
        onTap = () => _triggerSOS('SILENT');
        break;
      case ARANFeature.location:
        label = isTamil ? "என் இருப்பிடம்" : "MY LOCATION";
        icon = Icons.my_location;
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbySafetyScreen()));
        break;
      case ARANFeature.contacts:
        label = isTamil ? "அவசர தொடர்புகள்" : "EMERGENCY CONTACTS";
        icon = Icons.people_outline;
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactsScreen()));
        break;
      case ARANFeature.sms:
        label = isTamil ? "அவசர SMS" : "EMERGENCY SMS";
        icon = Icons.sms_outlined;
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencySessionScreen()));
        break;
      case ARANFeature.police:
        label = isTamil ? "காவல்துறை (100)" : "POLICE HELP (100)";
        icon = Icons.local_police_outlined;
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyServicesScreen()));
        break;
      case ARANFeature.hospital:
        label = isTamil ? "மருத்துவமனை" : "NEARBY HOSPITAL";
        icon = Icons.local_hospital_outlined;
        onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NearbySafetyScreen()));
        break;
      case ARANFeature.camera:
        label = isTamil ? "புகைப்படம்/வீடியோ எடு" : "CAPTURE EVIDENCE";
        icon = Icons.camera_alt_outlined;
        onTap = _handleEvidenceCapture;
        break;
      case ARANFeature.fakeCall:
        label = isTamil ? "போலி அழைப்பு" : "FAKE CALL";
        icon = Icons.phone_callback_outlined;
        onTap = _showFakeCallContactPicker;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFE91E63),
          elevation: 2,
          minimumSize: const Size(double.infinity, 55),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFFF8BBD0)),
          ),
        ),
      ),
    );
  }

  void _triggerSOS(String mode) {
    StorageService.isSOSActive = true;
    StorageService.sosMode = mode;
    StorageService.calledContactIds = [];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EmergencySessionScreen()),
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
            if (contacts.isEmpty)
              const Text("No contacts saved. Default will be used.")
            else
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
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color(0xFFE91E63), size: 40),
                        onPressed: () {
                          Navigator.pop(context);
                          _capture(ImageSource.camera, isVideo: false);
                        },
                      ),
                      const Text("PHOTO"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.videocam, color: Color(0xFF880E4F), size: 40),
                        onPressed: () {
                          Navigator.pop(context);
                          _capture(ImageSource.camera, isVideo: true);
                        },
                      ),
                      const Text("VIDEO"),
                    ],
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
}
