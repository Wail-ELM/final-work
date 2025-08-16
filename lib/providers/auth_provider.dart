import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Offline/demo modus vlag (geen fake data; enkel UI-gedrag/offline fallback)
final demoModeProvider = StateProvider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<Session?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Geen demo user meer; app is online-first met offline fallback

// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});
