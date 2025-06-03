class AppConstants {
  // Version de l'application
  static const String appVersion = '1.0.0';
  static const String appName = 'Social Balans';

  // Durées d'animation
  static const Duration fadeAnimationDuration = Duration(milliseconds: 1000);
  static const Duration slideAnimationDuration = Duration(milliseconds: 800);

  // Limites de validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxNoteLength = 500;

  // Valeurs par défaut
  static const int defaultScreenTimeGoalHours = 4;
  static const int maxMoodValue = 5;
  static const int minMoodValue = 1;

  // Messages
  static const String defaultErrorMessage =
      'Er is een onverwachte fout opgetreden';
  static const String networkErrorMessage = 'Controleer je internetverbinding';

  // URLs de redirection
  static const String mobileLoginCallback =
      'io.supabase.socialbalans://login-callback/';
  static const String mobileResetCallback =
      'io.supabase.socialbalans://reset-callback/';
}
