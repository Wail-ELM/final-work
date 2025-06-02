import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';

final moodsBoxProvider =
    Provider<Box<MoodEntry>>((ref) => Hive.box<MoodEntry>('moods'));

final moodsProvider =
    StateNotifierProvider<MoodsNotifier, List<MoodEntry>>((ref) {
  final box = ref.watch(moodsBoxProvider);
  final authService = ref.watch(authServiceProvider);
  final userDataService = ref.watch(userDataServiceProvider);
  return MoodsNotifier(box, authService, userDataService);
});

class MoodsNotifier extends StateNotifier<List<MoodEntry>> {
  MoodsNotifier(this._box, this._authService, this._userDataService)
      : super(_box.values.toList()) {
    _box.watch().listen((_) => state = _box.values.toList());
    _loadFromSupabase();
  }

  final Box<MoodEntry> _box;
  final AuthService _authService;
  final UserDataService _userDataService;

  Future<void> _loadFromSupabase() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      // Charger les entrées d'humeur depuis Supabase
      final entries = await _userDataService.getMoodEntries(userId: user.id);

      // Mettre à jour le cache local
      await _box.clear();
      for (final entry in entries) {
        await _box.put(entry.id, entry);
      }

      state = entries;
    } catch (e) {
      // En cas d'erreur, garder les données locales
      print('Erreur lors du chargement depuis Supabase: $e');
    }
  }

  Future<void> add(MoodEntry entry) async {
    // Sauvegarder localement d'abord
    await _box.put(entry.id, entry);
    state = [...state, entry];

    // Puis synchroniser avec Supabase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _userDataService.addMoodEntry(
          userId: user.id,
          moodValue: entry.moodValue,
          note: entry.note,
        );
      } catch (e) {
        print('Erreur lors de la synchronisation avec Supabase: $e');
        // TODO: Ajouter à une file d'attente pour retry plus tard
      }
    }
  }

  Future<void> removeAt(int index) async {
    if (index < 0 || index >= state.length) return;
    final entry = state[index];
    await _box.delete(entry.id);
    state = state.where((e) => e.id != entry.id).toList();
  }

  Future<void> remove(String id) async {
    await _box.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> refresh() async {
    await _loadFromSupabase();
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
    required this.todayMood,
    required this.lastWeekAverage,
    required this.recentEntries,
  });
}

final moodBoxProvider = Provider<Box<MoodEntry>>((ref) {
  return Hive.box<MoodEntry>('moods');
});

final moodEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  final box = ref.watch(moodBoxProvider);
  return Stream.value(box.values.toList());
});

final moodStatsProvider = Provider<MoodStats>((ref) {
  final moods = ref.watch(moodsProvider);

  if (moods.isEmpty) {
    return MoodStats(
      count: 0,
      averageMood: 0,
      todayMood: null,
      lastWeekAverage: 0,
      recentEntries: [],
    );
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekAgo = today.subtract(const Duration(days: 7));
  final twoWeeksAgo = today.subtract(const Duration(days: 14));

  // Filtrer les entrées
  final todayEntries = moods
      .where((e) =>
          e.createdAt.year == today.year &&
          e.createdAt.month == today.month &&
          e.createdAt.day == today.day)
      .toList();

  final thisWeekEntries = moods
      .where((e) => e.createdAt.isAfter(weekAgo) && e.createdAt.isBefore(now))
      .toList();

  final lastWeekEntries = moods
      .where((e) =>
          e.createdAt.isAfter(twoWeeksAgo) && e.createdAt.isBefore(weekAgo))
      .toList();

  // Calculer les moyennes
  final todayMood = todayEntries.isEmpty
      ? null
      : todayEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
          todayEntries.length;

  final averageMood = thisWeekEntries.isEmpty
      ? 0.0
      : thisWeekEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
          thisWeekEntries.length;

  final lastWeekAverage = lastWeekEntries.isEmpty
      ? 0.0
      : lastWeekEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
          lastWeekEntries.length;

  // Les 7 dernières entrées pour le graphique
  final recentEntries = moods.take(7).toList();

  return MoodStats(
    count: moods.length,
    averageMood: averageMood,
    todayMood: todayMood?.toDouble(),
    lastWeekAverage: lastWeekAverage,
    recentEntries: recentEntries,
  );
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
