import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/shake_service.dart';
import '../utils/translations.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Shake Detection'),
            subtitle: Text(Translations.get('shake_twice_desc', lang)),
            value: StorageService.shakeEnabled,
            activeThumbColor: Colors.red,
            onChanged: (val) {
              setState(() {
                StorageService.shakeEnabled = val;
                if (val) {
                  ShakeService.startListening(() {});
                } else {
                  ShakeService.stopListening();
                }
              });
            },
          ),
          SwitchListTile(
            title: const Text('Siren'),
            subtitle: const Text('Play loud audio on SOS'),
            value: StorageService.sirenEnabled,
            activeThumbColor: Colors.red,
            onChanged: (val) {
              setState(() => StorageService.sirenEnabled = val);
            },
          ),
          SwitchListTile(
            title: const Text('Flashlight'),
            subtitle: const Text('Blink flashlight on SOS'),
            value: StorageService.flashlightEnabled,
            activeThumbColor: Colors.red,
            onChanged: (val) {
              setState(() => StorageService.flashlightEnabled = val);
            },
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(StorageService.language),
            trailing: const Icon(Icons.language),
            onTap: _showLanguageDialog,
          ),
          ListTile(
            title: const Text('Emergency Countdown'),
            subtitle: Text('${StorageService.countdown} seconds'),
            trailing: const Icon(Icons.timer),
            onTap: _showCountdownDialog,
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen())),
          ),
          ListTile(
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              StorageService.isLoggedIn = false;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: ['English', 'Tamil'].map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => StorageService.language = lang);
              Navigator.pop(context);
            },
            child: Text(lang),
          );
        }).toList(),
      ),
    );
  }

  void _showCountdownDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Countdown Duration'),
        children: [3, 5, 10, 15].map((sec) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => StorageService.countdown = sec);
              Navigator.pop(context);
            },
            child: Text('$sec seconds'),
          );
        }).toList(),
      ),
    );
  }
}
