import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AuthService {
  // Haal client lui op zodat tests Supabase kunnen initialiseren vóór gebruik
  SupabaseClient get _supabase => Supabase.instance.client;
  final _uuid = const Uuid();

  // Auth status stream met initiële waarde (huidige sessie of null)
  // om eindeloze laadschermen te vermijden als er geen events komen.
  Stream<Session?> get authStateChanges async* {
    try {
      // Eerst de huidige sessie uitsturen (kan null zijn)
      final initial = _supabase.auth.currentSession;
      yield initial;

      // Daarna statuswijzigingen doorgeven
      yield* _supabase.auth.onAuthStateChange.map((event) => event.session);
    } catch (_) {
      // Supabase niet geïnitialiseerd: null uitsturen en netjes afsluiten
      yield null;
    }
  }

  // Huidige gebruiker
  User? get currentUser {
    try {
      return _supabase.auth.currentUser;
    } catch (_) {
      // Supabase niet geïnitialiseerd
      return null;
    }
  }

  // Registratie met e-mail/wachtwoord
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

      // DB-trigger handle_new_user() maakt automatisch het profiel aan

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Inloggen met e-mail/wachtwoord
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

  // Uitloggen
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Wachtwoord resetten
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo:
            kIsWeb ? null : 'io.supabase.socialbalans://reset-callback/',
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Bevestigingsmail opnieuw verzenden
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

  // Profiel bijwerken
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

  // Sessie token genereren
  String generateSessionToken() {
    final random = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$random$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // Afhandeling van authenticatiefouten
  AuthException _handleAuthError(dynamic error) {
    if (error is AuthException) {
      // Speciale afhandeling voor e-mailbevestiging
      if (error.message.toLowerCase().contains('email_not_confirmed') ||
          error.message.toLowerCase().contains('emailnotconfirmed')) {
        return const AuthException(
          'Je e-mailadres is nog niet bevestigd. Controleer je inbox en klik op de bevestigingslink, of vraag een nieuwe bevestigingsmail aan.',
          statusCode: '400',
        );
      }
      // Beheer van verlopen links
      if (error.message.toLowerCase().contains('otp_expired') ||
          error.message.toLowerCase().contains('link is invalid') ||
          error.message.toLowerCase().contains('has expired')) {
        return const AuthException(
          'De bevestigingslink is verlopen. Vraag een nieuwe bevestigingsmail aan.',
          statusCode: 'otp_expired',
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

// Provider voor de authenticatieservice
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider voor de authenticatiestatus
final authStateProvider = StreamProvider<Session?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider voor de huidige gebruiker
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});
