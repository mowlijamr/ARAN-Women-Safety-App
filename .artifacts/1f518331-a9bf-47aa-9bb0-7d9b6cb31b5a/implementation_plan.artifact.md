# Women Safety Application Implementation Plan

This plan outlines the steps to build a brand-new Women Safety emergency application in Flutter.

## Proposed Changes

### Configuration

#### [MODIFY] [pubspec.yaml](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/pubspec.yaml)
- Add dependencies: `shared_preferences`, `geolocator`, `permission_handler`, `url_launcher`, `audioplayers`, `shake`, `flutter_secure_storage`.
- Add asset declaration for `assets/audio/siren.mp3`.

#### [MODIFY] [AndroidManifest.xml](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/android/app/src/main/AndroidManifest.xml)
- Add required permissions: `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `SEND_SMS`, `CALL_PHONE`, `FLASHLIGHT`, `CAMERA`.

### Services Layer

#### [NEW] [storage_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/storage_service.dart)
- Handle SharedPreferences for local data (contacts, login state, settings).

#### [NEW] [location_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/location_service.dart)
- Handle GPS location using `geolocator`.

#### [NEW] [sms_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/sms_service.dart)
- Handle SMS sending or opening SMS composer.

#### [NEW] [call_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/call_service.dart)
- Handle emergency calls or opening dialer.

#### [NEW] [siren_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/siren_service.dart)
- Handle siren audio playback using `audioplayers`.

#### [NEW] [flashlight_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/flashlight_service.dart)
- Handle flashlight blinking.

#### [NEW] [shake_service.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/services/shake_service.dart)
- Handle shake detection using `shake`.

### Models

#### [NEW] [emergency_contact.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/models/emergency_contact.dart)
- Data model for emergency contacts.

### UI Screens

#### [NEW] [splash_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/splash_screen.dart)
#### [NEW] [login_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/login_screen.dart)
#### [NEW] [home_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/home_screen.dart)
#### [NEW] [contacts_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/contacts_screen.dart)
#### [NEW] [emergency_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/emergency_screen.dart)
#### [NEW] [emergency_services_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/emergency_services_screen.dart)
#### [NEW] [nearby_safety_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/nearby_safety_screen.dart)
#### [NEW] [safety_tips_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/safety_tips_screen.dart)
#### [NEW] [safety_codes_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/safety_codes_screen.dart)
#### [NEW] [profile_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/profile_screen.dart)
#### [NEW] [settings_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/settings_screen.dart)
#### [NEW] [about_screen.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/screens/about_screen.dart)

### Localization

#### [NEW] [translations.dart](file:///D:/OneDrive/Desktop/WOMEN_SAFTEY%20APP/lib/utils/translations.dart)
- Simple English/Tamil translation map.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting errors.
- Run `flutter build apk --debug` to verify the build.

### Manual Verification
- Test SOS flow: Pressing SOS triggers siren, flashlight, location, and countdown.
- Test Shake detection: Shaking triggers SOS.
- Test Contacts: Adding/Editing/Deleting contacts works and persists.
- Test Language: Switching between English and Tamil updates UI text.
- Test Emergency Services: Clicking on services opens dialer with correct number.
