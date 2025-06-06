import 'dart:io'; // Added for File type

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../models/screen_time_entry.dart';
import '../models/challenge.dart';
import 'package:path/path.dart' as p; // Added for path manipulation

final supabaseClient = Supabase.instance.client;

class UserDataService {
  final _supabase = supabaseClient;
  final String _avatarBucket = 'avatars'; // Define bucket name

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
    String? avatarUrl, // Can be null to remove avatar
    bool explicitlyUpdateAvatar =
        false, // Flag to indicate avatar is being updated
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      // If avatarUrl is explicitly passed (even as null), update it.
      if (explicitlyUpdateAvatar) {
        updates['avatar_url'] = avatarUrl;
      }

      if (updates.length > 1) {
        // Only update if there's more than just updated_at
      await _supabase.from('profiles').update(updates).eq('id', userId);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExtension = p.extension(imageFile.path);
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      // Path within the bucket: public/user_id/filename
      // Using 'public/' prefix is a common convention if you want files to be publicly accessible
      // without signed URLs, assuming your bucket policies allow it.
      // Otherwise, adjust the path as per your bucket structure and policies.
      final filePath = '$userId/$fileName';

      final storageResponse =
          await _supabase.storage.from(_avatarBucket).uploadBinary(
                filePath,
                await imageFile.readAsBytes(),
                fileOptions: FileOptions(
                  contentType:
                      'image/${fileExtension.substring(1)}', // e.g. image/jpeg, image/png
                  upsert: true, // Overwrite if file with same path exists
                ),
              );

      // Get public URL
      final publicUrlResponse =
          _supabase.storage.from(_avatarBucket).getPublicUrl(filePath);

      return publicUrlResponse;
    } catch (e) {
      // Log the error or handle it more gracefully
      print('Error uploading avatar: $e');
      if (e is StorageException) {
        print('StorageException details: ${e.message}');
      }
      throw _handleError(e);
    }
  }

  Future<void> deleteAvatar(String avatarUrl) async {
    if (avatarUrl.isEmpty) return; // No URL, nothing to delete

    try {
      // Extract the path from the URL.
      // Supabase public URLs typically look like:
      // https://<project-ref>.supabase.co/storage/v1/object/public/<bucket-name>/<path-to-file>
      // We need to extract <path-to-file> which includes any folders within the bucket.
      final uri = Uri.parse(avatarUrl);
      // The path segments would be ['storage', 'v1', 'object', 'public', <bucket-name>, ...actual_path_segments]
      // We need to find the segments after the bucket name.
      List<String> pathSegments = uri.pathSegments;
      int bucketNameIndex = pathSegments.indexOf(_avatarBucket);

      if (bucketNameIndex == -1 || bucketNameIndex + 1 >= pathSegments.length) {
        print('Could not determine avatar path from URL: $avatarUrl');
        return; // Or throw an error
      }

      final String avatarPath =
          pathSegments.sublist(bucketNameIndex + 1).join('/');

      if (avatarPath.isNotEmpty) {
        await _supabase.storage.from(_avatarBucket).remove([avatarPath]);
      }
    } catch (e) {
      print('Error deleting avatar from storage: $e');
      // Decide if this error should be re-thrown or handled silently
      // For now, just print, as failing to delete an old avatar might not be critical for UX
      // throw _handleError(e);
    }
  }

  Future<int> getUniqueMoodEntryDaysCount(String userId) async {
    try {
      final response = await _supabase.rpc(
        'get_unique_mood_days',
        params: {'p_user_id': userId},
      );
      // The RPC returns the count. Handle potential null response if no entries.
      return response as int? ?? 0;
    } catch (e) {
      print('Error fetching unique mood days count: $e');
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
      var query = _supabase.from('mood_entries').select().eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
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
      var query = _supabase.from('challenges').select().eq('user_id', userId);

      if (isDone != null) {
        query = query.eq('is_done', isDone);
      }

      final response = await query.order('created_at', ascending: false);
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
    if (error is StorageException) {
      // Added to handle StorageException
      return Exception('Storage error: ${error.message}');
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
