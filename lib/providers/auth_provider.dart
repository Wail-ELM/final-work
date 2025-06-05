import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<Session?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Mode démo : utilisateur de test
final demoUserProvider = Provider<User?>((ref) {
  // Créer un utilisateur fictif pour le mode démo
  return User(
    id: 'demo-user-123',
    appMetadata: {},
    userMetadata: {'name': 'Demo User'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
});

// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});
