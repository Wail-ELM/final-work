// lib/screens/journal.dart
import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _controller = TextEditingController();
  final List<String> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Schrijf iets over vandaag…',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isEmpty) return;
              setState(() {
                _entries.insert(0, _controller.text);
                _controller.clear();
              });
            },
            child: const Text('Toevoegen'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _entries.length,
              itemBuilder:
                  (context, i) => ListTile(
                    leading: const Icon(Icons.note),
                    title: Text(_entries[i]),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
