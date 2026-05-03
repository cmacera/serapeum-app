import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle Supabase authentication including anonymous login.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Guards against concurrent sign-in calls.
  /// If a sign-in is already in flight all callers await the same result.
  Completer<void>? _signInCompleter;

  /// Guards against concurrent refresh calls.
  /// If a refresh is already in flight all callers await the same result.
  Completer<bool>? _refreshCompleter;

  /// Checks if there's an existing session, and if not, signs in anonymously.
  /// Concurrent callers share the same in-flight request.
  Future<void> signInAnonymously() async {
    if (Supabase.instance.client.auth.currentSession != null) {
      debugPrint('Already signed in anonymously');
      return;
    }

    if (_signInCompleter != null) {
      return _signInCompleter!.future;
    }

    _signInCompleter = Completer<void>();
    try {
      await Supabase.instance.client.auth.signInAnonymously().timeout(
        const Duration(seconds: 15),
      );
      debugPrint('Anonymous sign in successful');
      _signInCompleter!.complete();
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
      _signInCompleter!.completeError(e);
      rethrow;
    } finally {
      _signInCompleter = null;
    }
  }

  /// Whether the current session is anonymous (no linked email/identity).
  bool get isAnonymous =>
      Supabase.instance.client.auth.currentUser?.isAnonymous ?? true;

  /// Email of the currently authenticated user, or null if anonymous.
  String? get currentUserEmail =>
      Supabase.instance.client.auth.currentUser?.email;

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
  ///
  /// If called concurrently, all callers share the same in-flight refresh
  /// rather than triggering multiple Supabase calls.
  Future<bool> refreshSession() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final response = await Supabase.instance.client.auth.refreshSession();
      final refreshed = response.session != null;
      if (refreshed) {
        debugPrint('Session refreshed successfully');
      } else {
        debugPrint('Session refresh returned no session');
      }
      _refreshCompleter!.complete(refreshed);
      return refreshed;
    } catch (e) {
      debugPrint('Failed to refresh session: $e');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
