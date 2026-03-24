import 'package:flutter/foundation.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';

/// Service to handle app startup authentication including anonymous login.
class SplashService {
  /// Performs authentication checks and setup on app startup.
  /// Returns a Future that completes with true if authentication is successful,
  /// or false if it persistently fails after retries.
  static Future<bool> initialize() async {
    // Sign in anonymously if needed
    final authService = AuthService();
    const maxAttempts = 3;

    for (var i = 1; i <= maxAttempts; i++) {
      try {
        await authService.signInAnonymously();
        return true;
      } catch (e, stackTrace) {
        debugPrint(
          'Failed to sign in anonymously (Attempt $i/$maxAttempts): $e\n$stackTrace',
        );
        if (i < maxAttempts) {
          // Exponential backoff: 1s, 2s
          await Future.delayed(Duration(seconds: 1 << (i - 1)));
        }
      }
    }

    debugPrint('All anonymous sign in attempts failed.');
    return false;
  }
}
