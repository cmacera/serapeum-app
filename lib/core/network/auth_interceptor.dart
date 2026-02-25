import 'package:dio/dio.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';

/// Key used in [RequestOptions.extra] to prevent infinite retry loops.
const _kRetryKey = 'auth_retry';

/// Dio interceptor that:
/// - Attaches a Bearer token to every request targeting the Serapeum API.
/// - On 401, attempts a session refresh and retries the request once.
///   If the refresh also fails the error is propagated to the caller.
class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final Dio _dio;

  AuthInterceptor(this._authService, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isSerapeumApi(options.uri)) {
      final token = _authService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized =
        err.type == DioExceptionType.badResponse &&
        err.response?.statusCode == 401;

    // Only attempt refresh once per request (guard via extra flag)
    final alreadyRetried = err.requestOptions.extra[_kRetryKey] == true;

    if (isUnauthorized &&
        !alreadyRetried &&
        _isSerapeumApi(err.requestOptions.uri)) {
      final refreshed = await _authService.refreshSession();

      if (refreshed) {
        // Guard: if the session was refreshed but no token is available,
        // propagate the original error rather than sending 'Bearer null'.
        final newToken = _authService.getAccessToken();
        if (newToken == null) {
          handler.next(err);
          return;
        }

        final retryOptions = err.requestOptions
          ..extra[_kRetryKey] = true
          ..headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await _dio.fetch(retryOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.reject(retryError);
          return;
        }
      }
    }

    super.onError(err, handler);
  }

  bool _isSerapeumApi(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == ApiConstants.productionHost ||
        host.endsWith('.${ApiConstants.productionHost}') ||
        host == ApiConstants.localhostHost ||
        host == ApiConstants.localhostIp ||
        host == ApiConstants.localhostIpV6 ||
        host == ApiConstants.androidEmulatorHost;
  }
}
