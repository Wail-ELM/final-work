import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/mood_entry.dart';

final moodsBoxProvider =
    Provider<Box<MoodEntry>>((ref) => Hive.box<MoodEntry>('moods'));

final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<MoodEntry>>((ref) {
  final box = ref.watch(moodsBoxProvider);
  return MoodsNotifier(box);
});

class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier(this._box) : super(_box.values.toList()) {
    _box.watch().listen((_) => state = _box.values.toList());
  }
  final Box<MoodEntry> _box;

  Future<void> add(MoodEntry entry) async {
    await _box.add(entry);
    state = _box.values.toList();
  }

  Future<void> removeAt(int index) async {
    await _box.deleteAt(index);
    state = _box.values.toList();
  }
}

class MoodStats {
  final int count;
  final double averageMood;
  final double? todayMood;
  final double lastWeekAverage;
  final List<MoodEntry> recentEntries;

  MoodStats({
    required this.count,
    required this.averageMood,
    this.todayMood,
    required this.lastWeekAverage,
    required this.recentEntries,
  });

  factory MoodStats.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodStats(
        count: 0,
        averageMood: 0,
        lastWeekAverage: 0,
        recentEntries: [],
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWeek = today.subtract(const Duration(days: 7));

    final todayEntries = entries
        .where((e) =>
            e.createdAt.year == today.year &&
            e.createdAt.month == today.month &&
            e.createdAt.day == today.day)
        .toList();

    final lastWeekEntries = entries
        .where(
            (e) => e.createdAt.isAfter(lastWeek) && e.createdAt.isBefore(today))
        .toList();

    final todayMood = todayEntries.isEmpty
        ? null
        : (todayEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
                todayEntries.length)
            .toDouble();

    final lastWeekAverage = lastWeekEntries.isEmpty
        ? 0.0
        : (lastWeekEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
                lastWeekEntries.length)
            .toDouble();

    final averageMood = entries.isEmpty
        ? 0.0
        : (entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
                entries.length)
            .toDouble();

    return MoodStats(
      count: entries.length,
      averageMood: averageMood,
      todayMood: todayMood,
      lastWeekAverage: lastWeekAverage,
      recentEntries: entries.take(7).toList(),
    );
  }
}

final moodBoxProvider = Provider<Box<MoodEntry>>((ref) {
  return Hive.box<MoodEntry>('moods');
});

final moodEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  final box = ref.watch(moodBoxProvider);
  return Stream.value(box.values.toList());
});

final moodStatsProvider = Provider<MoodStats>((ref) {
  final entries = ref.watch(moodEntriesProvider).value ?? [];
  return MoodStats.fromEntries(entries);
});

final addMoodEntryProvider =
    FutureProvider.family<void, MoodEntry>((ref, entry) async {
  final box = ref.read(moodBoxProvider);
  await box.add(entry);
});

final deleteMoodEntryProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final box = ref.read(moodBoxProvider);
  final entry = box.values.firstWhere((e) => e.id == id);
  await entry.delete();
});
