import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  static const String _serapeumApiUrlKey = 'SERAPEUM_API_URL';
  static const String _localhostApiUrl = 'http://localhost:3000';

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  // Not obfuscated — resolved at compile time via --dart-define so the
  // launch config (local vs remote) controls which URL is used.
  static const String apiUrl = String.fromEnvironment(
    _serapeumApiUrlKey,
    defaultValue: _localhostApiUrl,
  );

  /// Call once at app startup (e.g. in main()) to catch misconfigured builds.
  static void validate() {
    if (kReleaseMode && apiUrl == _localhostApiUrl) {
      throw StateError(
        '$_serapeumApiUrlKey resolves to localhost. '
        'Pass --dart-define=$_serapeumApiUrlKey=<url> when building for release.',
      );
    }
  }
}
