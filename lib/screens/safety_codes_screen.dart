import 'package:flutter/material.dart';

class SafetyCodesScreen extends StatefulWidget {
  const SafetyCodesScreen({super.key});

  @override
  State<SafetyCodesScreen> createState() => _SafetyCodesScreenState();
}

class _SafetyCodesScreenState extends State<SafetyCodesScreen> {
  // In a real app, these would be saved in SharedPreferences
  final List<Map<String, String>> _codes = [
    {'phrase': 'I forgot my book.', 'meaning': 'I am in an uncomfortable situation.'},
    {'phrase': 'I need you to call me.', 'meaning': 'Call me immediately with an excuse.'},
    {'phrase': 'Can you pick me up?', 'meaning': 'Come get me, I don\'t feel safe here.'},
  ];

  void _editCode(int index) {
    final phraseController = TextEditingController(text: _codes[index]['phrase']);
    final meaningController = TextEditingController(text: _codes[index]['meaning']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Safety Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: phraseController, decoration: const InputDecoration(labelText: 'Secret Phrase')),
            TextField(controller: meaningController, decoration: const InputDecoration(labelText: 'True Meaning')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _codes[index] = {
                  'phrase': phraseController.text,
                  'meaning': meaningController.text,
                };
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Codes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set secret phrases to use with trusted contacts to communicate distress discreetly.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _codes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      title: Text('"${_codes[index]['phrase']}"', style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      subtitle: Text('Means: ${_codes[index]['meaning']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editCode(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
