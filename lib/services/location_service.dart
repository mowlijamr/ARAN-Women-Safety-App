import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  error,
  timeout
}

class LocationResult {
  final LocationStatus status;
  final Position? position;
  final String? message;

  LocationResult({required this.status, this.position, this.message});
}

class LocationService {
  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          status: LocationStatus.servicesDisabled,
          message: 'Location services are disabled. Please enable GPS.'
        );
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            status: LocationStatus.permissionDenied,
            message: 'Location permissions are denied.'
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          status: LocationStatus.permissionDeniedForever,
          message: 'Location permissions are permanently denied. Please enable them in settings.'
        );
      }

      // Try to get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(status: LocationStatus.success, position: position);
    } on TimeoutException catch (e) {
      debugPrint('Location timeout: $e');
      // Try getting last known position as fallback
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LocationResult(status: LocationStatus.success, position: lastKnown);
      }
      return LocationResult(status: LocationStatus.timeout, message: 'Location request timed out.');
    } catch (e) {
      debugPrint('Error getting location: $e');
      return LocationResult(status: LocationStatus.error, message: e.toString());
    }
  }

  static String getGoogleMapsUrl(double lat, double lon) {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
  }

  static String getNearbySearchUrl(String category, double? lat, double? lon) {
    if (lat != null && lon != null) {
      // Using query format that works well for both app and browser
      return 'https://www.google.com/maps/search/${category.replaceAll(' ', '+')}+near+$lat,$lon';
    }
    return 'https://www.google.com/maps/search/${category.replaceAll(' ', '+')}+near+me';
  }
}
