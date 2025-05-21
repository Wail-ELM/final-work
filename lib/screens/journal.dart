import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);
  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _ctrl = TextEditingController();
  final List<String> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Schrijf iets…',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_ctrl.text.isEmpty) return;
            setState(() {
              _entries.insert(0, _ctrl.text);
              _ctrl.clear();
            });
          },
          child: const Text('Toevoegen'),
        ),
        const SizedBox(height: 16),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.note),
              title: Text(_entries[i]),
            ),
          ),
        ),
      ],
    );
  }
}
