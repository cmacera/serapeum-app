import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Env.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Env.supabaseAnonKey;

  // obfuscate: true for consistency; the URL is not a secret but we keep all
  // env fields obfuscated uniformly to avoid exposing build-time config in the binary.
  @EnviedField(varName: 'SERAPEUM_API_URL', obfuscate: true)
  static final String apiUrl = _Env.apiUrl;
}
