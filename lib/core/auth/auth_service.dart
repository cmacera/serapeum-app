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
        // The response object structure might be different in this version
        // We'll just ensure the call succeeded
        debugPrint('Anonymous sign in successful');
      } catch (e) {
        debugPrint('Failed to sign in anonymously: $e');
        // Re-throw the error so it can be handled by the caller
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
}
