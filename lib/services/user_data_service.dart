import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../models/screen_time_entry.dart';
import '../models/challenge.dart';

final supabaseClient = Supabase.instance.client;

class UserDataService {
  final _supabase = supabaseClient;

  // Profil utilisateur
  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Entrées d'humeur
  Future<List<MoodEntry>> getMoodEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('mood_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      return response.map((json) => MoodEntry.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addMoodEntry({
    required String userId,
    required int moodValue,
    String? note,
  }) async {
    try {
      await _supabase.from('mood_entries').insert({
        'user_id': userId,
        'mood_value': moodValue,
        'note': note,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Entrées de temps d'écran
  Future<List<ScreenTimeEntry>> getScreenTimeEntries({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final response = await _supabase
          .from('screen_time_entries')
          .select()
          .eq('user_id', userId)
          .eq('date', date.toIso8601String().split('T')[0])
          .order('created_at', ascending: false);

      return response.map((json) => ScreenTimeEntry.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addScreenTimeEntry({
    required String userId,
    required String appName,
    required Duration duration,
    required DateTime date,
  }) async {
    try {
      await _supabase.from('screen_time_entries').insert({
        'user_id': userId,
        'app_name': appName,
        'duration': duration.inSeconds,
        'date': date.toIso8601String().split('T')[0],
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Défis
  Future<List<Challenge>> getChallenges({
    required String userId,
    bool? isDone,
  }) async {
    try {
      var query = _supabase
          .from('challenges')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (isDone != null) {
        query = query.eq('is_done', isDone);
      }

      final response = await query;
      return response.map((json) => Challenge.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addChallenge({
    required String userId,
    required String title,
    required String description,
    required String category,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      await _supabase.from('challenges').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateChallenge({
    required String challengeId,
    String? title,
    String? description,
    String? category,
    DateTime? endDate,
    bool? isDone,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category;
      if (endDate != null) {
        updates['end_date'] = endDate.toIso8601String().split('T')[0];
      }
      if (isDone != null) updates['is_done'] = isDone;

      await _supabase.from('challenges').update(updates).eq('id', challengeId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Préférences utilisateur
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUserPreferences({
    required String userId,
    bool? notificationsEnabled,
    Duration? dailyScreenTimeGoal,
    List<String>? focusAreas,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notificationsEnabled != null) {
        updates['notifications_enabled'] = notificationsEnabled;
      }
      if (dailyScreenTimeGoal != null) {
        updates['daily_screen_time_goal'] = dailyScreenTimeGoal.inSeconds;
      }
      if (focusAreas != null) {
        updates['focus_areas'] = focusAreas;
      }

      await _supabase
          .from('user_preferences')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gestion des erreurs
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      return Exception(error.message);
    }
    return Exception('Er is een onverwachte fout opgetreden');
  }
}

// Providers
final userDataServiceProvider = Provider<UserDataService>((ref) {
  return UserDataService();
});

final userProfileProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    return ref.read(userDataServiceProvider).getProfile(userId);
  },
);

final userPreferencesProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, userId) async {
    return ref.read(userDataServiceProvider).getUserPreferences(userId);
  },
);

final moodEntriesProvider = FutureProvider.family<List<MoodEntry>,
    ({String userId, DateTime? startDate, DateTime? endDate})>(
  (ref, params) async {
    return ref.read(userDataServiceProvider).getMoodEntries(
          userId: params.userId,
          startDate: params.startDate,
          endDate: params.endDate,
        );
  },
);

final screenTimeEntriesProvider = FutureProvider.family<List<ScreenTimeEntry>,
    ({String userId, DateTime date})>(
  (ref, params) async {
    return ref.read(userDataServiceProvider).getScreenTimeEntries(
          userId: params.userId,
          date: params.date,
        );
  },
);

final challengesProvider =
    FutureProvider.family<List<Challenge>, ({String userId, bool? isDone})>(
  (ref, params) async {
    return ref.read(userDataServiceProvider).getChallenges(
          userId: params.userId,
          isDone: params.isDone,
        );
  },
);
