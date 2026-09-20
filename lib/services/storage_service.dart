import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  static bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;
  static set isLoggedIn(bool value) => _prefs.setBool('isLoggedIn', value);

  static bool get isSetupComplete => _prefs.getBool('isSetupComplete') ?? false;
  static set isSetupComplete(bool value) => _prefs.setBool('isSetupComplete', value);

  // User Info
  static String get userName => _prefs.getString('userName') ?? 'User';
  static set userName(String value) => _prefs.setString('userName', value);

  static String get userEmail => _prefs.getString('userEmail') ?? '';
  static set userEmail(String value) => _prefs.setString('userEmail', value);

  static String get profileImagePath => _prefs.getString('profileImagePath') ?? '';
  static set profileImagePath(String value) => _prefs.setString('profileImagePath', value);

  // Settings
  static bool get shakeEnabled => _prefs.getBool('shakeEnabled') ?? true;
  static set shakeEnabled(bool value) => _prefs.setBool('shakeEnabled', value);

  static bool get sirenEnabled => _prefs.getBool('sirenEnabled') ?? true;
  static set sirenEnabled(bool value) => _prefs.setBool('sirenEnabled', value);

  static bool get flashlightEnabled => _prefs.getBool('flashlightEnabled') ?? true;
  static set flashlightEnabled(bool value) => _prefs.setBool('flashlightEnabled', value);

  static String get language => _prefs.getString('language') ?? 'English';
  static set language(String value) => _prefs.setString('language', value);

  static int get countdown => _prefs.getInt('countdown') ?? 5;
  static set countdown(int value) => _prefs.setInt('countdown', value);

  // SOS Session State
  static bool get isSOSActive => _prefs.getBool('isSOSActive') ?? false;
  static set isSOSActive(bool value) => _prefs.setBool('isSOSActive', value);

  static List<String> get calledContactIds => _prefs.getStringList('calledContactIds') ?? [];
  static set calledContactIds(List<String> value) => _prefs.setStringList('calledContactIds', value);

  static String get sosMode => _prefs.getString('sosMode') ?? 'SIREN';
  static set sosMode(String value) => _prefs.setString('sosMode', value);

  static void clearSOSSession() {
    isSOSActive = false;
    calledContactIds = [];
    sosMode = 'SIREN';
  }

  // Contacts
  static List<EmergencyContact> getPersonalContacts() {
    final List<String>? contactsJson = _prefs.getStringList('emergency_contacts');
    if (contactsJson == null) return [];
    return contactsJson
        .map((item) => EmergencyContact.fromJson(jsonDecode(item)))
        .toList();
  }

  static List<EmergencyContact> getContacts() {
    final personalContacts = getPersonalContacts();
    
    // Add default contacts (100 - Police, 181 - Women Helpline)
    final defaultContacts = [
      EmergencyContact(id: 'police_100', name: 'Police Emergency', phoneNumber: '100'),
      EmergencyContact(id: 'women_181', name: 'Women Helpline', phoneNumber: '181'),
    ];
    
    return [...personalContacts, ...defaultContacts];
  }

  static Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final List<String> contactsJson =
        contacts.map((contact) => jsonEncode(contact.toJson())).toList();
    await _prefs.setStringList('emergency_contacts', contactsJson);
  }
}
