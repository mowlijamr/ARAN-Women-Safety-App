  import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  static StreamSubscription? _subscription;
  static bool _isTriggered = false;
  static bool _isPaused = false;

  // Sensitivity Tuning
  // 30.0 is the sweet spot for an intentional, single firm shake.
  static const double _shakeThreshold = 30.0; 
  static const Duration _cooldownDuration = Duration(seconds: 3);

  static void startListening(Function onShakeTriggered) {
    if (_subscription != null) {
      debugPrint("SHAKE LISTENER ALREADY ACTIVE - SKIPPING INIT");
      return;
    }
    
    debugPrint("SHAKE LISTENER STARTED (GLOBAL)");
    debugPrint("TARGET THRESHOLD: $_shakeThreshold");

    _subscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_isPaused) return;
      _handleAccelerometerEvent(event, onShakeTriggered);
    });
  }

  static void _handleAccelerometerEvent(AccelerometerEvent event, Function onTrigger) {
    if (_isTriggered) return;

    // Calculate magnitude (orientation independent)
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    
    // Net acceleration (magnitude - gravity)
    double netAcceleration = (magnitude - 9.81).abs();

    // Log significant movements for calibration on physical device
    if (netAcceleration > 10.0) { 
      debugPrint("ACCELERATION: ${netAcceleration.toStringAsFixed(2)} | TARGET: $_shakeThreshold");
    }

    if (netAcceleration > _shakeThreshold) {
      debugPrint("✅ SHAKE DETECTED (MAG: ${netAcceleration.toStringAsFixed(2)})");
      _isTriggered = true; // Cooldown lock
      debugPrint("SHAKE COOLDOWN ACTIVE");
      
      onTrigger();
      
      // Auto-reset after a short cooldown to prevent multiple triggers from one shake
      Timer(_cooldownDuration, () {
        if (_isTriggered) {
          debugPrint("SHAKE COOLDOWN FINISHED");
          _isTriggered = false;
        }
      });
    }
  }

  /// Explicitly reset to allow detection again (e.g. after SOS is cancelled)
  static void resetTrigger() {
    debugPrint("SHAKE SENSOR RESET MANUALLY");
    _isTriggered = false;
  }

  static void pause() {
    _isPaused = true;
    debugPrint("SHAKE LISTENER PAUSED (BACKGROUND)");
  }

  static void resume() {
    _isPaused = false;
    debugPrint("SHAKE LISTENER RESUMED (FOREGROUND)");
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isTriggered = false;
    debugPrint("SHAKE LISTENER STOPPED");
  }
}
