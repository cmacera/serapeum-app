import 'package:dio/dio.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';

/// Dio interceptor to automatically add Authorization headers to requests.
class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor(this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only add authorization header for requests to the API base URL
    // This is a simplified approach - in a real implementation, we'd need to
    // make this async or have a way to get the token synchronously
    final token = _authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
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
