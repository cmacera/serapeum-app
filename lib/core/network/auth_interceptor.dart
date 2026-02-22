import 'package:dio/dio.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';

/// Dio interceptor to automatically add Authorization headers to requests.
class AuthInterceptor extends Interceptor {
  final AuthService _authService;

  AuthInterceptor(this._authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Determine if request targets our backend
    final host = options.uri.host.toLowerCase();
    final isSerapeumApi =
        host == ApiConstants.productionHost ||
        host.endsWith('.${ApiConstants.productionHost}') ||
        host == ApiConstants.localhostHost ||
        host == ApiConstants.localhostIp ||
        host == ApiConstants.localhostIpV6 ||
        host == ApiConstants.androidEmulatorHost;

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
