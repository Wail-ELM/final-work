/// Stub multiplateforme pour le service web de temps d'écran.
/// Utilisé sur mobile/desktop pour éviter l'import de dart:html.
class WebScreenTimeService {
  static final WebScreenTimeService _instance = WebScreenTimeService._internal();
  factory WebScreenTimeService() => _instance;
  WebScreenTimeService._internal();

  Future<void> initialize() async {}
  Future<void> startTracking() async {}
  Future<void> stopTracking() async {}
  Duration getCurrentSessionDuration() => Duration.zero;
  bool get isTracking => false;
  bool get isCurrentlyActive => false;
  Map<String, dynamic> getDebugStats() => const {
    'isTracking': false,
    'isPageVisible': false,
    'isWindowFocused': false,
    'isActivelyUsing': false,
    'sessionStartTime': null,
    'currentSessionDuration': 0,
    'lastActiveTime': null,
  };
  void dispose() {}
}
