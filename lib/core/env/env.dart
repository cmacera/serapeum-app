import 'package:envied/envied.dart';

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
}
