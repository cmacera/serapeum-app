import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  // Not obfuscated — resolved at compile time via --dart-define so the
  // launch config (local vs remote) controls which URL is used.
  static const String apiUrl = String.fromEnvironment(
    'SERAPEUM_API_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Call once at app startup (e.g. in main()) to catch misconfigured builds.
  static void validate() {
    if (kReleaseMode && apiUrl == 'http://localhost:3000') {
      throw StateError(
        'SERAPEUM_API_URL is not set. '
        'Pass --dart-define=SERAPEUM_API_URL=<url> when building for release.',
      );
    }
  }
}
