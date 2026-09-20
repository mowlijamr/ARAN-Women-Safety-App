import 'package:telephony/telephony.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class SMSService {
  static final Telephony telephony = Telephony.instance;

  static Future<bool> sendEmergencySMS(String recipient, String message) async {
    if (kIsWeb) return false;

    try {
      // Request SMS permission
      var status = await Permission.sms.request();
      if (!status.isGranted) {
        debugPrint("SMS permission denied");
        return false;
      }

      await telephony.sendSms(
        to: recipient,
        message: message,
      );
      debugPrint("SMS sent to $recipient");
      return true;
    } catch (e) {
      debugPrint("Error sending SMS to $recipient: $e");
      return false;
    }
  }

  static String generateEmergencyMessage(double? lat, double? lon) {
    if (lat != null && lon != null) {
      String mapsLink = "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
      return "I'm in an emergency. Please help me. My current location: $mapsLink";
    } else {
      return "I'm in an emergency. Please help me. My current location is currently unavailable.";
    }
  }
}
