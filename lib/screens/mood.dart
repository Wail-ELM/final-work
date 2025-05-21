// lib/screens/mood.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int? _selectedMood;
  final _noteController = TextEditingController();
  static const _moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  @override
  Widget build(BuildContext context) {
    final isValid = _selectedMood != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Mijn stemming registreren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Hoe voel je je?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_moodIcons.length, (i) {
                final sel = i == _selectedMood;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: Icon(
                    _moodIcons[i],
                    size: sel ? 48 : 36,
                    color: sel
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notitie (optioneel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid
                    ? () async {
                        final entry = MoodEntry(
                          id: const Uuid().v4(),
                          date: DateTime.now(),
                          emoji: '', // on ignore l’emoji car on a un indice
                          value: _selectedMood! + 1, // 1 à 5
                          note: _noteController.text.isEmpty
                              ? null
                              : _noteController.text,
                        );
                        await ref.read(moodsProvider.notifier).add(entry);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Stemming opgeslagen')),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
                child: const Text('Opslaan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
