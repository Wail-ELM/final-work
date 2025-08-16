// Offline helper: keep only a stable local demo user id and detection helper.

class DemoDataService {
  static const String _demoUserId = "demo-user-123";

  /// Check si on est en mode hors-ligne (ancien "démo")
  static bool isDemoMode(String? userId) {
    return userId == null || userId == _demoUserId;
  }

  /// ID de l'utilisateur démo
  static String get demoUserId => _demoUserId;
}
 