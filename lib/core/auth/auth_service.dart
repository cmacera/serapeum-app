import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle Supabase authentication including anonymous login.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Checks if there's an existing session, and if not, signs in anonymously.
  Future<void> signInAnonymously() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      // No existing session, sign in anonymously
      try {
        await Supabase.instance.client.auth.signInAnonymously();
        debugPrint('Anonymous sign in successful');
      } catch (e) {
        debugPrint('Failed to sign in anonymously: $e');
        rethrow;
      }
    } else {
      debugPrint('Already signed in anonymously');
    }
  }

  /// Gets the current access token from Supabase.
  /// Returns null if no session exists.
  String? getAccessToken() {
    final session = Supabase.instance.client.auth.currentSession;
    return session?.accessToken;
  }

  /// Attempts to refresh the current Supabase session.
  ///
  /// Returns `true` if the refresh succeeded (a new access token is available),
  /// or `false` if it failed (session is gone or network error).
  Future<bool> refreshSession() async {
    try {
      final response = await Supabase.instance.client.auth.refreshSession();
      final refreshed = response.session != null;
      if (refreshed) {
        debugPrint('Session refreshed successfully');
      } else {
        debugPrint('Session refresh returned no session');
      }
      return refreshed;
    } catch (e) {
      debugPrint('Failed to refresh session: $e');
      return false;
    }
  }
}
