import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';

/// Riverpod provider for the [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
