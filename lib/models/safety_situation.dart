import 'package:flutter/material.dart';

enum ARANFeature {
  sos,
  silentSos,
  location,
  contacts,
  sms,
  police,
  hospital,
  camera,
  fakeCall
}

class SafetySituation {
  final String id;
  final String titleEnglish;
  final String titleTamil;
  final String responseEnglish;
  final String responseTamil;
  final List<ARANFeature> recommendedFeatures;
  final IconData icon;

  SafetySituation({
    required this.id,
    required this.titleEnglish,
    required this.titleTamil,
    required this.responseEnglish,
    required this.responseTamil,
    required this.recommendedFeatures,
    required this.icon,
  });
}
