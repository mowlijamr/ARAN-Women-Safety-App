import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'services/storage_service.dart';
import 'services/shake_service.dart';
import 'services/siren_service.dart';
import 'services/flashlight_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/safety_tips_screen.dart';
import 'screens/emergency_session_screen.dart';
import 'utils/translations.dart';

// Global key to access the navigation state and trigger SOS from anywhere
final GlobalKey<MainNavigationScreenState> mainNavKey = GlobalKey<MainNavigationScreenState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const WomenSafetyApp());
}

class AppColors {
  static const Color primary = Color(0xFFE91E63); // Rich Pink
  static const Color secondary = Color(0xFFF8BBD0); // Soft Pink
  static const Color background = Color(0xFFFFF1F5); // Very Light Pink
  static const Color accentMaroon = Color(0xFF880E4F); // Dark Maroon for contrast
  static const Color textDark = Color(0xFF2D2D2D);
}

class AranTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: Colors.white,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.accentMaroon, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARAN | அரண்',
      debugShowCheckedModeBanner: false,
      theme: AranTheme.light,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => MainNavigationScreen(key: mainNavKey),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  
  // Global SOS State
  Timer? _countdownTimer;
  int _countdown = 3;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSOS();
    _initShake();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    ShakeService.stopListening();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ShakeService.pause();
    } else if (state == AppLifecycleState.resumed) {
      ShakeService.resume();
    }
  }

  void _checkSOS() {
    if (StorageService.isSOSActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSession();
      });
    }
  }

  void _initShake() {
    if (StorageService.shakeEnabled) {
      // Initialize only once. The service handles duplicate calls internally.
      ShakeService.startListening(() {
        // Triggered by shake
        if (!_isCountingDown && !StorageService.isSOSActive) {
          triggerSOS(mode: 'SIREN');
        }
      });
    }
  }

  // Public method to trigger SOS (called by shake or button)
  void triggerSOS({required String mode}) {
    if (StorageService.isSOSActive || _isCountingDown) return;

    if (mode == 'SILENT') {
      _activateSOS(mode: 'SILENT');
      return;
    }

    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    debugPrint("SOS COUNTDOWN STARTED");

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        if (mounted) setState(() => _countdown--);
      } else {
        _activateSOS(mode: 'SIREN');
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    ShakeService.resetTrigger();
    setState(() {
      _isCountingDown = false;
      _countdown = 3;
    });
  }

  Future<void> _activateSOS({required String mode}) async {
    _countdownTimer?.cancel();
    
    if (mounted) {
      setState(() {
        _isCountingDown = false;
      });
    }

    StorageService.isSOSActive = true;
    StorageService.sosMode = mode;
    StorageService.calledContactIds = [];

    if (mode == 'SIREN') {
      debugPrint("SIREN STARTED");
      SirenService.startSiren();
      if (!kIsWeb) {
        FlashlightService.startBlinking();
      }
    }

    _navigateToSession();
  }

  void _navigateToSession() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencySessionScreen()),
    ).then((_) {
      // Re-init state when returning from session
      if (mounted) {
        setState(() {
          _isCountingDown = false;
          _countdown = 3;
        });
      }
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const EmergencyScreen(),
    const SafetyTipsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_isCountingDown) _buildCountdownOverlay(lang),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: Translations.get('home', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.warning_amber_outlined),
            activeIcon: const Icon(Icons.warning),
            label: Translations.get('emergency', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.security_outlined),
            activeIcon: const Icon(Icons.security),
            label: Translations.get('safety', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: Translations.get('profile', lang),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay(String lang) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 80),
          const SizedBox(height: 20),
          Text(
            Translations.get('emergency_activated', lang),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _countdown / 3,
                  strokeWidth: 12,
                  color: const Color(0xFFE91E63),
                  backgroundColor: Colors.white10,
                ),
              ),
              Text(
                '$_countdown',
                style: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: _cancelCountdown,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(220, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(Translations.get('cancel', lang).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
