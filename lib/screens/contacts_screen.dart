import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_contact.dart';
import '../services/storage_service.dart';
import '../utils/translations.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<EmergencyContact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    setState(() {
      _contacts = StorageService.getPersonalContacts();
    });
  }

  void _addOrEditContact({EmergencyContact? contact}) {
    final lang = StorageService.language;
    final nameController = TextEditingController(text: contact?.name);
    final phoneController = TextEditingController(text: contact?.phoneNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          contact == null ? Translations.get('add_contact', lang) : Translations.get('edit_contact', lang),
          style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: Translations.get('name', lang),
                filled: true,
                fillColor: const Color(0xFFF8BBD0).withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: const Color(0xFFF8BBD0).withValues(alpha: 0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.get('cancel', lang), style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
              
              final newContact = EmergencyContact(
                id: contact?.id ?? const Uuid().v4(),
                name: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
              );

              if (contact == null) {
                if (_contacts.length >= 3) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 3 contacts allowed')));
                  return;
                }
                _contacts.add(newContact);
              } else {
                final index = _contacts.indexWhere((c) => c.id == contact.id);
                _contacts[index] = newContact;
              }

              StorageService.saveContacts(_contacts);
              _loadContacts();
              Navigator.pop(context);
            },
            child: Text(Translations.get('save', lang)),
          ),
        ],
      ),
    );
  }

  void _deleteContact(String id) {
    setState(() {
      _contacts.removeWhere((c) => c.id == id);
      StorageService.saveContacts(_contacts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = StorageService.language;
    return Scaffold(
      appBar: AppBar(title: Text(Translations.get('emergency_contacts', lang))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              lang == 'English' ? 'Manage your trusted people' : 'உங்கள் நம்பகமான நபர்களை நிர்வகிக்கவும்',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF880E4F)),
            ),
            const SizedBox(height: 5),
            const Text(
              'These contacts will be alerted in case of emergency.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            if (_contacts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No personal contacts saved.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF8BBD0),
                        child: Icon(Icons.person, color: Color(0xFFE91E63)),
                      ),
                      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(contact.phoneNumber),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                            onPressed: () => _addOrEditContact(contact: contact),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFE91E63), size: 22),
                            onPressed: () => _deleteContact(contact.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            const Text(
              "Default Emergency Services",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            _buildDefaultContactCard("Police Emergency", "100"),
            _buildDefaultContactCard("Women Helpline", "181"),
          ],
        ),
      ),
      floatingActionButton: _contacts.length < 3
          ? FloatingActionButton.extended(
              onPressed: () => _addOrEditContact(),
              icon: const Icon(Icons.add),
              label: Text(Translations.get('add_contact', lang)),
            )
          : null,
    );
  }

  Widget _buildDefaultContactCard(String name, String number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.grey.shade50,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.emergency, color: Colors.white, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number),
        trailing: const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
      ),
    );
  }
}
