import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

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
    final moodEntries = ref.watch(moodsProvider);
    final isValid = _selectedMood != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Stemming bijhouden')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Hoe voel je je vandaag?', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_moodIcons.length, (i) {
              final selected = i == _selectedMood;
              return IconButton(
                icon: Icon(
                  _moodIcons[i],
                  color:
                      selected ? Theme.of(context).primaryColor : Colors.grey,
                  size: selected ? 40 : 32,
                ),
                onPressed: () => setState(() => _selectedMood = i),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Schrijf een opmerking (optioneel)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isValid
                ? () async {
                    final entry = MoodEntry(
                      id: const Uuid().v4(),
                      userId: ref.read(currentUserProvider)?.uid ?? '',
                      moodValue: _selectedMood! + 1,
                      note: _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(moodsProvider.notifier).add(entry);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stemming opgeslagen')),
                    );
                    _noteController.clear();
                    setState(() => _selectedMood = null);
                  }
                : null,
            child: const Text('Opslaan'),
          ),
          const Divider(height: 32),
          const Text('Vorige stemmingen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: moodEntries.length,
              itemBuilder: (_, i) {
                final entry = moodEntries[i];
                return ListTile(
                  leading: Icon(
                    _moodIcons[entry.moodValue - 1],
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(entry.note ?? '(geen opmerking)'),
                  subtitle: Text('${entry.createdAt.toLocal()}'.split(' ')[0]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        ref.read(moodsProvider.notifier).removeAt(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
