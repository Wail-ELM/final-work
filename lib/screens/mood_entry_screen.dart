import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../services/demo_data_service.dart';
import '../models/mood_entry.dart';
import 'package:uuid/uuid.dart';

class MoodEntryScreen extends ConsumerStatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  ConsumerState<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends ConsumerState<MoodEntryScreen>
    with TickerProviderStateMixin {
  int _selectedMood = 3; // Standaard stemming (neutraal)
  final _noteController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<MoodData> _moods = [
    MoodData(1, '😢', 'Erg verdrietig', Colors.red),
    MoodData(2, '😕', 'Verdrietig', Colors.orange),
    MoodData(3, '😐', 'Neutraal', Colors.yellow),
    MoodData(4, '😊', 'Blij', Colors.lightGreen),
    MoodData(5, '😄', 'Erg blij', Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMoodEntry() async {
    setState(() => _isLoading = true);

    try {
  final user = ref.read(authServiceProvider).currentUser;

      final moodEntry = MoodEntry(
        id: const Uuid().v4(),
  userId: user?.id ?? DemoDataService.demoUserId,
        moodValue: _selectedMood,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(moodsProvider.notifier).add(moodEntry);

      if (mounted) {
        await _scaleController.forward();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Stemming opgeslagen! ${_moods[_selectedMood - 1].emoji}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Fout bij opslaan: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoe voel je je?'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMoodSelector(),
              const SizedBox(height: 32),
              _buildSelectedMoodDisplay(),
              const SizedBox(height: 32),
              _buildNoteSection(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecteer je stemming',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods
                  .map((mood) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _buildMoodButton(mood),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(MoodData mood) {
    final isSelected = _selectedMood == mood.value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMood = mood.value);
        _scaleController.reset();
        _scaleController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? mood.color.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: isSelected ? mood.color : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mood.color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: ScaleTransition(
          scale:
              isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: Center(
            child: Text(
              mood.emoji,
              style: TextStyle(
                fontSize: isSelected ? 26 : 22,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMoodDisplay() {
    final selectedMoodData = _moods[_selectedMood - 1];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: selectedMoodData.color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: selectedMoodData.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    selectedMoodData.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gekozen stemming',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedMoodData.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: selectedMoodData.color.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voeg een notitie toe (optioneel)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Beschrijf wat je stemming vandaag beïnvloedt...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMoodEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: _moods[_selectedMood - 1].color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Bewaar mijn stemming',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class MoodData {
  final int value;
  final String emoji;
  final String label;
  final Color color;

  MoodData(this.value, this.emoji, this.label, this.color);
}
