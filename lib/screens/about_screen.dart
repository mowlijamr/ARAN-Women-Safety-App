import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Women Safety')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.security, size: 80, color: Colors.red),
            ),
            const SizedBox(height: 30),
            const Text(
              'About Women Safety',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Women Safety is an emergency assistance application designed to help users quickly respond to dangerous situations by activating an SOS alert, siren, flashlight, emergency contacts, location sharing and access to emergency services.',
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _FeatureItem(text: 'SOS Emergency Countdown'),
            _FeatureItem(text: 'Shake Detection (Shake twice)'),
            _FeatureItem(text: 'Loud Emergency Siren'),
            _FeatureItem(text: 'Visual Flashlight Alert'),
            _FeatureItem(text: 'Trusted Emergency Contacts'),
            _FeatureItem(text: 'GPS Location Sharing'),
            _FeatureItem(text: 'One-tap Emergency Services (Police, Ambulance, Helpline)'),
            _FeatureItem(text: 'Nearby Safety Places Finder'),
            _FeatureItem(text: 'Safety Tips & Secret Codes'),
            _FeatureItem(text: 'Tamil & English Support'),
            const SizedBox(height: 50),
            const Center(
              child: Column(
                children: [
                  Text('Created by M.R. Mowlija', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('Department of Electronics and Communication Engineering', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 20),
                  Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}
