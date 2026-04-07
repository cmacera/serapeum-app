import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serapeum_app/core/auth/auth_service.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/auth_interceptor.dart';

class MockAuthService extends Mock implements AuthService {}

class MockDio extends Mock implements Dio {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeDioException extends Fake implements DioException {}

class FakeResponse extends Fake implements Response<dynamic> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeDioException());
    registerFallbackValue(FakeResponse());
  });

  late MockAuthService mockAuthService;
  late MockDio mockDio;
  late AuthInterceptor interceptor;

  setUp(() {
    mockAuthService = MockAuthService();
    mockDio = MockDio();
    interceptor = AuthInterceptor(mockAuthService, mockDio);
  });

  // ---------------------------------------------------------------------------
  // onRequest
  // ---------------------------------------------------------------------------
  group('onRequest', () {
    test('adds Authorization header for Serapeum production host', () {
      when(() => mockAuthService.getAccessToken()).thenReturn('test-token');
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], equals('Bearer test-token'));
      verify(() => handler.next(options)).called(1);
    });

    test('adds Authorization header for localhost', () {
      when(() => mockAuthService.getAccessToken()).thenReturn('local-token');
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/api/test',
        baseUrl: 'http://localhost:3000',
      );

      interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], equals('Bearer local-token'));
      verify(() => handler.next(options)).called(1);
    });

    test('does NOT add Authorization header for non-Serapeum hosts', () {
      when(() => mockAuthService.getAccessToken()).thenReturn('test-token');
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/query',
        baseUrl: 'https://external-api.com',
      );

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });

    test('skips Authorization header when token is null', () {
      when(() => mockAuthService.getAccessToken()).thenReturn(null);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );

      interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => handler.next(options)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // onError — 401 handling
  // ---------------------------------------------------------------------------
  group('onError — 401', () {
    test(
      'refreshes session and retries with new token and retry flag',
      () async {
        when(
          () => mockAuthService.refreshSession(),
        ).thenAnswer((_) async => true);
        when(() => mockAuthService.getAccessToken()).thenReturn('new-token');

        final retryRequestOptions = RequestOptions(path: '/api/test');
        final retryResponse = Response(
          requestOptions: retryRequestOptions,
          statusCode: 200,
        );

        // Capture the RequestOptions passed to dio.fetch so we can assert
        // it has the new token header and the retry sentinel set.
        RequestOptions? capturedOptions;
        when(() => mockDio.fetch<dynamic>(any())).thenAnswer((
          invocation,
        ) async {
          capturedOptions =
              invocation.positionalArguments.first as RequestOptions;
          return retryResponse;
        });

        final handler = MockErrorInterceptorHandler();
        final requestOptions = RequestOptions(
          path: '/api/test',
          baseUrl: 'https://${ApiConstants.productionHost}',
        );
        final err = DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 401),
          type: DioExceptionType.badResponse,
        );

        await interceptor.onError(err, handler);

        verify(() => mockAuthService.refreshSession()).called(1);
        verify(() => handler.resolve(retryResponse)).called(1);
        verifyNever(() => handler.next(any()));

        // Assert the retry request was wired with the new token and retry marker
        expect(capturedOptions, isNotNull);
        expect(
          capturedOptions!.headers['Authorization'],
          equals('Bearer new-token'),
        );
        expect(capturedOptions!.extra['auth_retry'], isTrue);
      },
    );

    test('propagates error when refresh fails on 401', () async {
      when(
        () => mockAuthService.refreshSession(),
      ).thenAnswer((_) async => false);

      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(err, handler);

      verify(() => mockAuthService.refreshSession()).called(1);
      verify(() => handler.next(err)).called(1);
      verifyNever(() => mockDio.fetch<dynamic>(any()));
    });

    test('propagates error when refresh succeeds but token is null', () async {
      when(
        () => mockAuthService.refreshSession(),
      ).thenAnswer((_) async => true);
      when(() => mockAuthService.getAccessToken()).thenReturn(null);

      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(err, handler);

      verify(() => mockAuthService.refreshSession()).called(1);
      verify(() => handler.next(err)).called(1);
      verifyNever(() => mockDio.fetch<dynamic>(any()));
    });

    test('propagates DioException thrown during retry fetch', () async {
      when(
        () => mockAuthService.refreshSession(),
      ).thenAnswer((_) async => true);
      when(() => mockAuthService.getAccessToken()).thenReturn('new-token');

      final retryRequestOptions = RequestOptions(path: '/api/test');
      final retryError = DioException(
        requestOptions: retryRequestOptions,
        type: DioExceptionType.connectionError,
      );
      when(() => mockDio.fetch<dynamic>(any())).thenThrow(retryError);

      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(err, handler);

      verify(() => mockDio.fetch<dynamic>(any())).called(1);
      verify(() => handler.reject(retryError)).called(1);
      verifyNever(() => handler.next(any()));
    });

    test(
      'does not retry if already retried (prevents infinite loop)',
      () async {
        final handler = MockErrorInterceptorHandler();
        final requestOptions = RequestOptions(
          path: '/api/test',
          baseUrl: 'https://${ApiConstants.productionHost}',
          extra: {'auth_retry': true},
        );
        final err = DioException(
          requestOptions: requestOptions,
          response: Response(requestOptions: requestOptions, statusCode: 401),
          type: DioExceptionType.badResponse,
        );

        await interceptor.onError(err, handler);

        verifyNever(() => mockAuthService.refreshSession());
        verify(() => handler.next(err)).called(1);
      },
    );

    test('does not attempt refresh for non-Serapeum 401 responses', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: '/query',
        baseUrl: 'https://external-api.com',
      );
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(err, handler);

      verifyNever(() => mockAuthService.refreshSession());
      verify(() => handler.next(err)).called(1);
    });

    test('passes through non-401 errors unchanged', () async {
      final handler = MockErrorInterceptorHandler();
      final requestOptions = RequestOptions(
        path: '/api/test',
        baseUrl: 'https://${ApiConstants.productionHost}',
      );
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 500),
        type: DioExceptionType.badResponse,
      );

      await interceptor.onError(err, handler);

      verifyNever(() => mockAuthService.refreshSession());
      verify(() => handler.next(err)).called(1);
    });
  });
}
