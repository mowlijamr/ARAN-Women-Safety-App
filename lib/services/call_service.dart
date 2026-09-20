import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> makeCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch dialer';
    }
  }
}
