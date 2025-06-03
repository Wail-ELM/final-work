import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

final supabaseClient = Supabase.instance.client;

class AuthService {
  final _supabase = supabaseClient;
  final _uuid = const Uuid();

  // Stream des changements d'état d'authentification
  Stream<Session?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) => event.session);

  // Utilisateur actuel
  User? get currentUser => _supabase.auth.currentUser;

  // Inscription avec email/mot de passe
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      // Le trigger handle_new_user() va créer automatiquement le profil
      // Pas besoin de créer manuellement le profil ici

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Connexion avec email/mot de passe
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Connexion avec Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.socialbalans://login-callback/',
      );

      // signInWithOAuth returns a bool, we need to create an AuthResponse
      if (response) {
        // Wait for auth state to update and get the session
        final session = _supabase.auth.currentSession;
        return AuthResponse(
          session: session,
          user: session?.user,
        );
      } else {
        throw const AuthException(
          'Failed to sign in with Google',
          statusCode: '401',
        );
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.socialbalans://reset-callback/',
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Renvoyer un email de confirmation
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Mise à jour du profil
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
      throw _handleAuthError(e);
    }
  }

  // Génération d'un token de session
  String generateSessionToken() {
    final random = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$random$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Gestion des erreurs d'authentification
  AuthException _handleAuthError(dynamic error) {
    if (error is AuthException) {
      // Gestion spéciale pour l'erreur de confirmation d'email
      if (error.message.toLowerCase().contains('email_not_confirmed') ||
          error.message.toLowerCase().contains('emailnotconfirmed')) {
        return const AuthException(
          'Je e-mailadres is nog niet bevestigd. Controleer je inbox en klik op de bevestigingslink, of vraag een nieuwe bevestigingsmail aan.',
          statusCode: '400',
        );
      }
      return error;
    }
    return const AuthException(
      'Er is een onverwachte fout opgetreden',
      statusCode: '500',
    );
  }
}

// Provider pour le service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider pour l'état d'authentification
final authStateProvider = StreamProvider<Session?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider pour l'utilisateur actuel
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});
