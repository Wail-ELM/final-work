// lib/screens/mood.dart
import 'package:flutter/material.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({Key? key}) : super(key: key);

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMoodIndex;

  static const _moods = [
    {'icon': Icons.sentiment_very_satisfied, 'label': 'Zeer goed'},
    {'icon': Icons.sentiment_satisfied, 'label': 'Goed'},
    {'icon': Icons.sentiment_neutral, 'label': 'Neutraal'},
    {'icon': Icons.sentiment_dissatisfied, 'label': 'Slecht'},
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'Zeer slecht'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stemming')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Hoe voel je je nu?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              itemCount: _moods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, i) {
                final mood = _moods[i];
                final selected = i == _selectedMoodIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMoodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      mood['icon'] as IconData,
                      size: selected ? 40 : 32,
                      color:
                          selected
                              ? Theme.of(context).primaryColor
                              : Colors.black54,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  _selectedMoodIndex == null
                      ? null
                      : () {
                        final label = _moods[_selectedMoodIndex!]['label'];
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Stemming geregistreerd: $label'),
                          ),
                        );
                      },
              child: const Text('Opslaan'),
            ),
          ],
        ),
      ),
    );
  }
}
