import 'package:dio/dio.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';

/// Dio interceptor to automatically add Authorization headers to requests.
class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor(this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Determine if request targets our backend
    final host = options.uri.host;
    final isSerapeumApi =
        host == 'serapeum.app' ||
        host.endsWith('.serapeum.app') ||
        host == 'localhost' ||
        host == '10.0.2.2';

    if (isSerapeumApi) {
      final token = _authService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.badResponse &&
        err.response?.statusCode == 401) {
      // Handle unauthorized access - could refresh token or redirect to login
      // For now, we'll just pass through and let the calling code handle it
    }
    super.onError(err, handler);
  }
}
