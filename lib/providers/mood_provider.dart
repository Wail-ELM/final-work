import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/mood_entry.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import '../services/demo_data_service.dart';
import 'package:flutter/foundation.dart';

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
  // Humeur ingaven laden vanuit Supabase
      final entries = await _userDataService.getMoodEntries(userId: user.id);

  // Lokaal cache bijwerken
      await _box.clear();
      for (final entry in entries) {
        await _box.put(entry.id, entry);
      }

      state = entries;
    } catch (e) {
  // Bij fout: lokale gegevens behouden
  debugPrint('Fout bij laden vanuit Supabase: $e');
    }
  }

  Future<void> add(MoodEntry entry) async {
  // Eerst lokaal opslaan
  await _box.put(entry.id, entry);
    state = [...state, entry];

  // Daarna synchroniseren met Supabase
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _userDataService.addMoodEntry(
          userId: user.id,
          moodValue: entry.moodValue,
          note: entry.note,
          id: entry.id,
          createdAt: entry.createdAt,
        );
      } catch (e) {
    debugPrint('Fout bij synchronisatie met Supabase: $e');
    // TODO: Toevoegen aan wachtrij voor later opnieuw proberen
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

  factory MoodStats.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodStats(
        count: 0,
        averageMood: 0.0,
        todayMood: null,
        lastWeekAverage: 0.0,
        recentEntries: [],
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWeek = now.subtract(const Duration(days: 7));

    // Entrées récentes (30 derniers jours)
    final recentEntries = entries.where((entry) {
      return entry.createdAt.isAfter(now.subtract(const Duration(days: 30)));
    }).toList();

    // Moyenne générale
    final averageMood = entries.isEmpty
        ? 0.0
        : entries.map((e) => e.moodValue).reduce((a, b) => a + b) /
            entries.length;

    // Mood d'aujourd'hui
    final todayEntries = entries.where((entry) {
      final entryDate = DateTime(
          entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      return entryDate.isAtSameMomentAs(today);
    }).toList();
    final todayMood = todayEntries.isEmpty
        ? null
        : todayEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
            todayEntries.length;

    // Moyenne de la semaine dernière
    final lastWeekEntries = entries.where((entry) {
      return entry.createdAt.isAfter(lastWeek);
    }).toList();
    final lastWeekAverage = lastWeekEntries.isEmpty
        ? 0.0
        : lastWeekEntries.map((e) => e.moodValue).reduce((a, b) => a + b) /
            lastWeekEntries.length;

    return MoodStats(
      count: entries.length,
      averageMood: averageMood,
      todayMood: todayMood?.toDouble(),
      lastWeekAverage: lastWeekAverage,
      recentEntries: recentEntries,
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
  // Maak afhankelijk van de actuele lijst uit moodsProvider (reactief op box.watch)
  final allEntries = ref.watch(moodsProvider);
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  try {
    final effectiveUserId = currentUser?.id ?? DemoDataService.demoUserId;
    final entries = allEntries
        .where((entry) => entry.userId == effectiveUserId)
        .toList();
    return MoodStats.fromEntries(entries);
  } catch (e) {
    debugPrint('Fout bij berekenen van stemmingsstatistieken: $e');
    return MoodStats(
      count: 0,
      averageMood: 3.0,
      todayMood: null,
      lastWeekAverage: 3.0,
      recentEntries: [],
    );
  }
});

final moodSyncProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Geen sync als geen gebruiker ingelogd is
  if (currentUser == null) {
    return;
  }

  try {
    final userDataService = ref.read(userDataServiceProvider);
    final moodEntries =
        await userDataService.getMoodEntries(userId: currentUser.id);

    final box = Hive.box<MoodEntry>('moods');
    await box.clear();

    for (final entry in moodEntries) {
  await box.put(entry.id, entry);
    }
  } catch (e) {
    // Bij fout: lokale gegevens behouden
    debugPrint('Fout bij laden vanuit Supabase: $e');
  }
});

final addMoodEntryProvider =
    FutureProvider.family<void, MoodEntry>((ref, entry) async {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;

  // Offline toevoegen: schrijf lokaal zelfs zonder ingelogde gebruiker
  final box = Hive.box<MoodEntry>('moods');
  await box.put(entry.id, entry);

  // Then try to sync if a user is logged in
  if (currentUser != null) {
    try {
      final userDataService = ref.read(userDataServiceProvider);
      await userDataService.addMoodEntry(
  userId: entry.userId,
  moodValue: entry.moodValue,
  note: entry.note,
  id: entry.id,
  createdAt: entry.createdAt,
      );
    } catch (e) {
      debugPrint('Fout bij synchronisatie met Supabase: $e');
      // TODO: Toevoegen aan wachtrij voor later opnieuw proberen
    }
  }
});

final deleteMoodEntryProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final box = ref.read(moodBoxProvider);
  final entry = box.values.firstWhere((e) => e.id == id);
  await entry.delete();
});
