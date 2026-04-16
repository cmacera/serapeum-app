import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/repositories/catalog_search_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CatalogSearchRepository repository;

  setUp(() {
    mockDio = MockDio();
    repository = CatalogSearchRepository(mockDio);

    registerFallbackValue(RequestOptions(path: ''));
  });

  group('searchAll (Aggregator)', () {
    test('should call /searchAll and parse SearchAllResponseDto', () async {
      // arrange
      when(
        () => mockDio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {
              'books': [
                {'title': 'Direct Book', 'id': '2'},
              ],
            },
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      final result = await repository.searchAll('query');

      // assert
      verify(
        () => mockDio.post<dynamic>(
          ApiConstants.searchAll,
          data: {
            'data': {'query': 'query'},
          },
        ),
      ).called(1);
      expect(result.books.first.title, 'Direct Book');
    });
  });

  group('Catalog Searches (Books, Media, Games)', () {
    test('searchBooks should pass language if provided', () async {
      // arrange
      when(
        () => mockDio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {'results': [], 'page': 1, 'hasMore': false},
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      // act
      await repository.searchBooks('query', language: 'es');

      // assert
      verify(
        () => mockDio.post<dynamic>(
          ApiConstants.searchBooks,
          data: {
            'data': {'query': 'query', 'language': 'es'},
          },
        ),
      ).called(1);
    });

    test('searchMedia should handle empty results', () async {
      when(
        () => mockDio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'result': {'results': [], 'page': 1, 'hasMore': false},
          },
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
        ),
      );

      final result = await repository.searchMedia('query');
      expect(result.results, isEmpty);
      expect(result.hasMore, isFalse);
    });
  });

  group('Error Handling', () {
    test('should map 500 status code to ServerFailure', () async {
      when(
        () => mockDio.post<dynamic>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.searchAll('query'),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
