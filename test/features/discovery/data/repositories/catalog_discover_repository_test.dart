import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/repositories/catalog_discover_repository.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CatalogDiscoverRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = CatalogDiscoverRepository(mockDio);

    registerFallbackValue(RequestOptions(path: ''));
  });

  group('CatalogDiscoverRepository Protocol (Genkit)', () {
    test(
      'should wrap request in "data" and extract "result" from response',
      () async {
        // arrange
        const query = 'hello';
        final mockData = {
          'result': {'kind': 'refusal', 'message': 'conversational response'},
        };

        when(
          () => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: mockData,
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        // act
        final result = await repository.orchestrate(query);

        // assert
        verify(
          () => mockDio.post<dynamic>(
            ApiConstants.orchestratorFlow,
            data: {'data': containsPair('query', query)},
            options: any(named: 'options'),
          ),
        ).called(1);
        expect(result, isA<OrchestratorMessage>());
        expect((result as OrchestratorMessage).text, 'conversational response');
      },
    );

    test('should propagate language parameter to backend', () async {
      // arrange
      const query = 'hello';
      const language = 'es';
      final mockResponse = {
        'result': {'kind': 'refusal', 'message': 'response'},
      };

      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockResponse,
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      await repository.orchestrate(query, language: language);

      // assert
      verify(
        () => mockDio.post<dynamic>(
          ApiConstants.orchestratorFlow,
          data: {
            'data': {'query': query, 'language': language},
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test(
      'should throw UnknownFailure when response "result" is missing',
      () async {
        // arrange
        when(
          () => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {'not_result': 'error'},
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        // act & assert
        expect(
          () => repository.orchestrate('query'),
          throwsA(isA<UnknownFailure>()),
        );
      },
    );
  });

  group('orchestrate (AI Orchestrator)', () {
    test('should handle refusal as OrchestratorMessage', () async {
      // arrange
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {'kind': 'refusal', 'message': 'Hello from AI'},
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      final result = await repository.orchestrate('hi');

      // assert
      expect(result, isA<OrchestratorMessage>());
      expect((result as OrchestratorMessage).text, 'Hello from AI');
    });

    test('should handle search_results kind as OrchestratorGeneral', () async {
      // arrange
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {
              'kind': 'search_results',
              'message': 'Combined results',
              'data': {
                'books': [
                  {'title': 'Book 1', 'id': '1'},
                ],
              },
            },
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      final result = await repository.orchestrate('find books');

      // assert
      expect(result, isA<OrchestratorGeneral>());
      final general = result as OrchestratorGeneral;
      expect(general.text, 'Combined results');
      expect(general.data.books, hasLength(1));
      expect(general.data.books.first.title, 'Book 1');
    });

    test('should handle error kind as OrchestratorError', () async {
      // arrange
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {
              'kind': 'error',
              'error': 'API Error',
              'details': 'Something went wrong',
            },
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      final result = await repository.orchestrate('broken query');

      // assert
      expect(result, isA<OrchestratorError>());
      final error = result as OrchestratorError;
      expect(error.error, 'API Error');
      expect(error.details, 'Something went wrong');
    });
  });

  group('Error Handling', () {
    test(
      'should map DioException connection error to NetworkFailure',
      () async {
        // arrange
        when(
          () => mockDio.post<dynamic>(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // act & assert
        expect(
          () => repository.orchestrate('query'),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });
}
