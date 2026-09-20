import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/translations.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

class NearbySafetyScreen extends StatefulWidget {
  const NearbySafetyScreen({super.key});

  @override
  State<NearbySafetyScreen> createState() => _NearbySafetyScreenState();
}

class _NearbySafetyScreenState extends State<NearbySafetyScreen> {
  LocationResult _locationResult = LocationResult(status: LocationStatus.initial);

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _locationResult = LocationResult(status: LocationStatus.loading);
    });

    final result = await LocationService.getCurrentLocation();
    
    if (mounted) {
      setState(() {
        _locationResult = result;
      });
    }
  }

  Future<void> _launchMapsUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    try {
      // First try to launch in external application (Google Maps app)
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // Fallback to platform default (browser)
        launched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      }
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open maps. Please try again.")),
        );
      }
    } catch (e) {
      debugPrint('Launch Error: $e');
      // Final attempt with basic launch if everything else fails
      try {
        await launchUrl(url);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to open map link.")),
          );
        }
      }
    }
  }

  void _openGoogleMapsSearch(String category) {
    final lat = _locationResult.position?.latitude;
    final lon = _locationResult.position?.longitude;
    final urlString = LocationService.getNearbySearchUrl(category, lat, lon);
    _launchMapsUrl(urlString);
  }

  void _viewCurrentLocationOnMap() async {
    if (_locationResult.status != LocationStatus.success) {
      await _fetchLocation();
    }
    
    if (!mounted) return;

    if (_locationResult.status == LocationStatus.success && _locationResult.position != null) {
      final lat = _locationResult.position!.latitude;
      final lon = _locationResult.position!.longitude;
      final urlString = LocationService.getGoogleMapsUrl(lat, lon);
      _launchMapsUrl(urlString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_locationResult.message ?? "Location unavailable. Please enable GPS and permissions.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F5),
      appBar: AppBar(
        title: Text(Translations.get('my_location', lang)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLocation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentLocationCard(lang),
              const SizedBox(height: 30),
              Text(
                Translations.get('nearby_safe_places', lang),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
              ),
              const SizedBox(height: 15),
              _buildNearbyCategories(lang),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard(String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF880E4F), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.my_location, size: 60, color: Colors.white),
          const SizedBox(height: 15),
          const Text(
            'Your Exact Location',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildLocationStatusDisplay(),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: _viewCurrentLocationOnMap,
            icon: const Icon(Icons.map),
            label: const Text('VIEW ON MAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF880E4F),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusDisplay() {
    switch (_locationResult.status) {
      case LocationStatus.loading:
        return const Column(
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10),
            Text('Acquiring GPS Signal...', style: TextStyle(color: Colors.white70)),
          ],
        );
      case LocationStatus.success:
        return Column(
          children: [
            Text(
              "Lat: ${_locationResult.position!.latitude.toStringAsFixed(6)}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              "Lon: ${_locationResult.position!.longitude.toStringAsFixed(6)}",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              "Accuracy: ±${_locationResult.position!.accuracy.toStringAsFixed(1)}m",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );
      default:
        return Column(
          children: [
            Text(
              _locationResult.message ?? 'Location Not Detected',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _fetchLocation,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('RETRY', style: TextStyle(decoration: TextDecoration.underline)),
            ),
          ],
        );
    }
  }

  Widget _buildNearbyCategories(String lang) {
    return Column(
      children: [
        _SearchCard(
          title: "Nearby Police Stations",
          icon: Icons.local_police_outlined,
          onTap: () => _openGoogleMapsSearch('police station'),
        ),
        _SearchCard(
          title: "Nearby Hospitals",
          icon: Icons.local_hospital_outlined,
          onTap: () => _openGoogleMapsSearch('hospital'),
        ),
        _SearchCard(
          title: "Emergency Services",
          icon: Icons.emergency_outlined,
          onTap: () => _openGoogleMapsSearch('emergency services'),
        ),
        _SearchCard(
          title: "Fire & Rescue",
          icon: Icons.fire_truck_outlined,
          onTap: () => _openGoogleMapsSearch('fire station'),
        ),
        _SearchCard(
          title: "Pharmacies",
          icon: Icons.medication_outlined,
          onTap: () => _openGoogleMapsSearch('pharmacy'),
        ),
      ],
    );
  }
}

class _SearchCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF8BBD0).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFFE91E63)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D2D2D))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
