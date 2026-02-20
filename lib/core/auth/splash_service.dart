import 'package:flutter/foundation.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';

/// Service to handle app startup authentication including anonymous login.
class SplashService {
  /// Performs authentication checks and setup on app startup.
  /// Returns a Future that completes when authentication is ready.
  static Future<void> initialize() async {
    // Initialize Supabase (if not already initialized)
    // This would typically be done in main.dart or a dedicated Supabase initialization
    // For now, we'll assume Supabase is already initialized

    // Sign in anonymously if needed
    final authService = AuthService();
    try {
      await authService.signInAnonymously();
    } catch (e) {
      // Log error but don't crash the app
      debugPrint('Failed to sign in anonymously: $e');
      // Consider showing an error to user or retry mechanism
    }
  }
}
