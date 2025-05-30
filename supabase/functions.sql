-- Fonctions utiles pour Social Balans

-- 1. Fonction pour obtenir les statistiques d'humeur
CREATE OR REPLACE FUNCTION get_mood_statistics(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  WITH mood_stats AS (
    SELECT 
      AVG(mood_value) as average_mood,
      COUNT(*) as total_entries,
      MAX(mood_value) as best_mood,
      MIN(mood_value) as worst_mood,
      COUNT(DISTINCT DATE(created_at)) as days_tracked
    FROM mood_entries
    WHERE user_id = p_user_id
      AND created_at >= NOW() - INTERVAL '30 days'
  ),
  mood_trend AS (
    SELECT 
      CASE 
        WHEN COUNT(*) < 2 THEN 'insufficient_data'
        WHEN AVG(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN mood_value END) > 
             AVG(CASE WHEN created_at < NOW() - INTERVAL '7 days' THEN mood_value END) THEN 'improving'
        WHEN AVG(CASE WHEN created_at >= NOW() - INTERVAL '7 days' THEN mood_value END) < 
             AVG(CASE WHEN created_at < NOW() - INTERVAL '7 days' THEN mood_value END) THEN 'declining'
        ELSE 'stable'
      END as trend
    FROM mood_entries
    WHERE user_id = p_user_id
      AND created_at >= NOW() - INTERVAL '14 days'
  )
  SELECT json_build_object(
    'average_mood', COALESCE(average_mood, 0),
    'total_entries', COALESCE(total_entries, 0),
    'best_mood', COALESCE(best_mood, 0),
    'worst_mood', COALESCE(worst_mood, 0),
    'days_tracked', COALESCE(days_tracked, 0),
    'trend', trend
  ) INTO result
  FROM mood_stats, mood_trend;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 2. Fonction pour analyser le temps d'écran
CREATE OR REPLACE FUNCTION analyze_screen_time(
  p_user_id UUID,
  p_start_date DATE,
  p_end_date DATE
)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  WITH daily_stats AS (
    SELECT 
      date,
      SUM(duration) as total_seconds,
      COUNT(DISTINCT app_name) as apps_used,
      json_object_agg(app_name, duration) as app_breakdown
    FROM screen_time_entries
    WHERE user_id = p_user_id
      AND date BETWEEN p_start_date AND p_end_date
    GROUP BY date
  ),
  summary AS (
    SELECT 
      AVG(total_seconds) as avg_daily_seconds,
      MAX(total_seconds) as max_daily_seconds,
      MIN(total_seconds) as min_daily_seconds,
      SUM(total_seconds) as total_seconds,
      COUNT(*) as days_tracked
    FROM daily_stats
  ),
  top_apps AS (
    SELECT 
      app_name,
      SUM(duration) as total_duration
    FROM screen_time_entries
    WHERE user_id = p_user_id
      AND date BETWEEN p_start_date AND p_end_date
    GROUP BY app_name
    ORDER BY total_duration DESC
    LIMIT 5
  )
  SELECT json_build_object(
    'avg_daily_hours', COALESCE(avg_daily_seconds / 3600.0, 0),
    'max_daily_hours', COALESCE(max_daily_seconds / 3600.0, 0),
    'min_daily_hours', COALESCE(min_daily_seconds / 3600.0, 0),
    'total_hours', COALESCE(total_seconds / 3600.0, 0),
    'days_tracked', COALESCE(days_tracked, 0),
    'top_apps', COALESCE((SELECT json_agg(row_to_json(t)) FROM top_apps t), '[]'::json),
    'daily_breakdown', COALESCE((SELECT json_agg(row_to_json(d)) FROM daily_stats d), '[]'::json)
  ) INTO result
  FROM summary;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 3. Fonction pour obtenir les défis actifs
CREATE OR REPLACE FUNCTION get_active_challenges(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  category TEXT,
  start_date DATE,
  end_date DATE,
  days_remaining INTEGER,
  progress_percentage INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.title,
    c.description,
    c.category,
    c.start_date,
    c.end_date,
    CASE 
      WHEN c.end_date IS NULL THEN NULL
      ELSE GREATEST(0, (c.end_date - CURRENT_DATE))
    END as days_remaining,
    CASE 
      WHEN c.end_date IS NULL THEN NULL
      ELSE LEAST(100, 
        ROUND(
          ((CURRENT_DATE - c.start_date)::NUMERIC / 
          NULLIF((c.end_date - c.start_date)::NUMERIC, 0)) * 100
        )::INTEGER
      )
    END as progress_percentage
  FROM challenges c
  WHERE c.user_id = p_user_id
    AND c.is_done = FALSE
    AND (c.end_date IS NULL OR c.end_date >= CURRENT_DATE)
  ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- 4. Vue pour les suggestions de défis basées sur les données
CREATE OR REPLACE VIEW challenge_suggestions AS
WITH user_stats AS (
  SELECT 
    u.id as user_id,
    AVG(m.mood_value) as avg_mood,
    AVG(s.duration) as avg_screen_time
  FROM auth.users u
  LEFT JOIN mood_entries m ON u.id = m.user_id 
    AND m.created_at >= NOW() - INTERVAL '7 days'
  LEFT JOIN screen_time_entries s ON u.id = s.user_id 
    AND s.date >= CURRENT_DATE - INTERVAL '7 days'
  GROUP BY u.id
)
SELECT 
  user_id,
  CASE 
    WHEN avg_screen_time > 14400 THEN 'Réduire le temps d écran de 30 minutes par jour'
    WHEN avg_mood < 3 THEN 'Pratiquer 10 minutes de méditation quotidienne'
    ELSE 'Maintenir un journal de gratitude'
  END as suggested_challenge,
  CASE 
    WHEN avg_screen_time > 14400 THEN 'screenTime'
    WHEN avg_mood < 3 THEN 'focus'
    ELSE 'notifications'
  END as category
FROM user_stats; 