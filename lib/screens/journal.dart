import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final journalBoxProvider = Provider<Box<String>>((ref) => Hive.box<String>('journal_entries'));

final journalProvider = StateNotifierProvider<JournalNotifier, List<String>>((ref) {
  final box = ref.watch(journalBoxProvider);
  return JournalNotifier(box);
});

class JournalNotifier extends StateNotifier<List<String>> {
  final Box<String> _box;

  JournalNotifier(this._box) : super(_box.values.toList());

  void add(String entry) {
    _box.add(entry);
    state = _box.values.toList().reversed.toList();
  }

  void delete(int index) {
    final key = _box.keyAt(index);
    _box.delete(key);
    state = _box.values.toList().reversed.toList();
  }

  void update(int index, String newText) {
    final key = _box.keyAt(index);
    _box.put(key, newText);
    state = _box.values.toList().reversed.toList();
  }
}

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _controller = TextEditingController();
  int? _editingIndex;

  @override
  Widget build(BuildContext context) {
    final journalEntries = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dagboek')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Schrijf je gedachten op...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isEmpty) return;

                      if (_editingIndex != null) {
                        ref.read(journalProvider.notifier).update(_editingIndex!, text);
                        _editingIndex = null;
                      } else {
                        ref.read(journalProvider.notifier).add(text);
                      }

                      _controller.clear();
                    },
                    child: Text(_editingIndex == null ? 'Toevoegen' : 'Bijwerken'),
                  ),
                ),
                if (_editingIndex != null)
                  const SizedBox(width: 10),
                if (_editingIndex != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _editingIndex = null);
                    },
                    child: const Text('Annuleer'),
                  )
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: journalEntries.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final entry = journalEntries[i];
                  return ListTile(
                    title: Text(entry),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _controller.text = entry;
                            setState(() => _editingIndex = i);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref.read(journalProvider.notifier).delete(i),
                        ),
                      ],
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
