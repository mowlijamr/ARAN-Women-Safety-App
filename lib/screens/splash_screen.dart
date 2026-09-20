import 'package:flutter/material.dart';
import 'dart:async';
import '../services/storage_service.dart';
import '../utils/translations.dart';
import '../widgets/aran_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (StorageService.isLoggedIn || StorageService.isSetupComplete) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AranLogo(size: 150),
            const SizedBox(height: 30),
            const Text(
              'ARAN | அரண்',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE91E63),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              Translations.get('tagline', lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Color(0xFFE91E63),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
