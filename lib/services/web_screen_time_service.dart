// Conditional export wrapper for WebScreenTimeService
// Exporte l'implémentation web uniquement sur le web, sinon stub neutre.
export 'web_screen_time_service_stub.dart' if (dart.library.html) 'web_screen_time_service_web.dart';
