import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static final SupabaseClient client = Supabase.instance.client;

  // Configuration des politiques RLS (Row Level Security)
  static const String rlsPolicies = '''
    -- Politique pour mood_entries
    CREATE POLICY "Users can only see their own mood entries" ON mood_entries
      FOR ALL USING (auth.uid() = user_id);
    
    -- Politique pour challenges
    CREATE POLICY "Users can only manage their own challenges" ON challenges
      FOR ALL USING (auth.uid() = user_id);
  ''';

  // Fonctions de base de données utiles
  static Future<Map<String, dynamic>> getMoodStatistics(String userId) async {
    try {
      final response = await client.rpc('get_mood_statistics', params: {
        'p_user_id': userId,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting mood statistics: $e');
      return {};
    }
  }

  // Subscription temps réel pour les challenges
  static Stream<List<Map<String, dynamic>>> subscribeToChallenges(
      String userId) {
    return client
        .from('challenges')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at');
  }

  // Fonction pour analyser le temps d'écran
  static Future<Map<String, dynamic>> analyzeScreenTime(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await client.rpc('analyze_screen_time', params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error analyzing screen time: $e');
      return {};
    }
  }

  // Backup local avec Hive en cas de perte de connexion
  static void enableOfflineMode() {
    // Votre logique Hive existante fonctionne bien pour ça
  }
}

// Exemple de fonction PostgreSQL pour les statistiques
const String createMoodStatisticsFunction = r'''
CREATE OR REPLACE FUNCTION get_mood_statistics(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'average_mood', AVG(mood_value),
    'total_entries', COUNT(*),
    'mood_trend', 
      CASE 
        WHEN AVG(mood_value) > LAG(AVG(mood_value)) OVER (ORDER BY DATE_TRUNC('week', created_at)) 
        THEN 'improving'
        ELSE 'stable'
      END,
    'best_day', MAX(mood_value),
    'worst_day', MIN(mood_value)
  ) INTO result
  FROM mood_entries
  WHERE user_id = p_user_id
  AND created_at >= NOW() - INTERVAL '30 days';
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;
''';
