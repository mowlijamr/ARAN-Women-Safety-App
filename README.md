# ARAN – Women Safety & Emergency Assistance

🏆 **1st Prize Winner – Women Hackathon 2026**

## About ARAN

ARAN is a women safety application designed to provide quick, situation-based emergency assistance through multiple safety features in a single platform. It is engineered to perform reliably under stress, offering discreet and highly visible alert mechanisms depending on the user's immediate threat level.

## Key Features

- **SOS**: Immediate loud alarm and flashlight signaling.
- **Silent SOS**: Discreet emergency alert without sound or light.
- **Shake Detection**: Shake the phone firmly once to instantly trigger the SOS flow.
- **SOS Siren**: High-decibel alarm to attract nearby attention.
- **Flashlight**: SOS pattern blinking to alert surroundings.
- **Emergency Call**: Direct dialing from the app interface.
- **Emergency SMS with Location**: Automated SMS containing real-time GPS coordinates.
- **Up to 3 Emergency Contacts**: Quick-dial your trusted circle.
- **Evidence Capture**: Rapid photo and video recording directly saved to the device gallery.
- **Fake Call**: Simulated incoming call to escape awkward or suspicious situations.
- **Nearby Police Stations**: Location-aware mapping to the closest law enforcement.
- **Nearby Hospitals**: Location-aware mapping to emergency medical care.
- **Nearby Safe Places**: Immediate routing to secure public zones.
- **100 & 181 Emergency Services**: Dedicated, permanent quick-dial buttons for Indian Emergency Police (100) and the Women Helpline (181).
- **Tamil & English Support**: Fully bilingual interface.
- **Offline Safety Guide**: 20 situational safety guides instantly accessible without an internet connection.

## How ARAN Works

1. **User faces an unsafe situation.**
2. **Choose the appropriate safety feature:** The user can press the on-screen buttons or simply perform a single intentional physical shake of the device.
3. **Emergency Trigger (SOS / Silent SOS / Shake):** Depending on the choice, the app immediately locks into an emergency state.
4. **Emergency Response:** For an active SOS, a 3-second countdown initiates, followed by the Siren and Flashlight.
5. **Emergency Communication:** The app fetches the user's real-time GPS coordinates and provides an immediate prompt to SMS the location to the trusted contacts and allows for immediate emergency dialing.
6. **Resolution:** The emergency state remains locked to prevent accidental cancellation until the user explicitly stops the session.

## Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Stateful Widgets & Local Persistence
- **Hardware Integration**: 
  - `sensors_plus` (Accelerometer for Shake Detection)
  - `geolocator` (GPS and Network Location)
  - `torch_light` (Device Flashlight)
  - `image_picker` & `gal` (Camera and Gallery Management)
  - `audioplayers` (Siren Audio)
  - `telephony` (Background SMS capabilities)

## Project Structure

- `lib/main.dart` - Application entry point, global navigation, and global shake detection listener.
- `lib/screens/` - Contains all UI views including Home, Emergency Session, Profile, and Offline Safety Guide.
- `lib/services/` - Core business logic including ShakeService, LocationService, SMSService, and StorageService.
- `lib/utils/` - Static data, configuration, and bilingual translation mapping (`translations.dart`).
- `lib/models/` - Data structures like `EmergencyContact` and `SafetySituation`.

## Installation

Ensure you have the Flutter SDK (version compatible with Dart 3.12.2 or higher) installed.

```bash
git clone <repository-url>
cd aran-women-safety
flutter pub get
flutter run
```

## Android Build

To generate a release build for the Google Play Store:

```bash
flutter build appbundle --release
```

To generate an APK for direct device installation or testing:

```bash
flutter build apk --release
```

## Permissions

ARAN requires the following permissions to function effectively:

- **Location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`)**: To retrieve exact GPS coordinates for the Emergency SMS and map navigation.
- **SMS (`SEND_SMS`)**: To send emergency alerts to trusted contacts.
- **Phone (`CALL_PHONE`)**: To dial emergency services (100/181) directly from the app.
- **Camera (`CAMERA`)**: To capture photographic and video evidence.
- **Storage/Media (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`)**: To safely store captured evidence locally on the device gallery.
- **Flashlight (`FLASHLIGHT`)**: To blink the device torch during an active SOS.

## Privacy & Safety

ARAN is designed with user privacy as a core principle. Sensitive permissions such as location, contacts, SMS, calls, and camera are utilized **exclusively** for executing relevant safety functionality during an emergency. The application does not track user location in the background when an emergency is not active, nor does it upload personal contact data to any remote server. 

## Disclaimer

ARAN is a safety assistance application. It is a tool designed to aid communication and attract attention during distress. It should **not** be described or relied upon as a guaranteed replacement for official emergency services, professional medical help, or law enforcement intervention. 
