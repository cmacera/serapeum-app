import 'package:dio/dio.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/catalog_search_input_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_discovery_repository.dart';

class _OrchestratorResponseKeys {
  static const String data = 'data';
  static const String result = 'result';
  static const String movies = 'movies';
  static const String media = 'media';
  static const String books = 'books';
  static const String games = 'games';
  static const String errors = 'errors';
  static const String error = 'error';
}

/// Concrete implementation of [IDiscoveryRepository] using Dio.
class DiscoveryRepository implements IDiscoveryRepository {
  final Dio _dio;

  const DiscoveryRepository(this._dio);

  Future<T> _post<T>(
    String path,
    Map<String, dynamic> dataPayload,
    T Function(dynamic data) converter,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: {_OrchestratorResponseKeys.data: dataPayload},
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw UnknownFailure(
          'Unexpected response format: expected Map, got ${responseData.runtimeType}',
        );
      }

      final result = responseData[_OrchestratorResponseKeys.result];
      if (result == null) {
        throw const UnknownFailure('Empty or null results from server');
      }

      return converter(result);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<SearchAllResponse> searchAll(
    String query, {
    String? language,
  }) => _post<SearchAllResponse>(
    ApiConstants.orchestratorFlow,
    CatalogSearchInputDto(query: query, language: language).toJson(),
    (data) {
      if (data is String) {
        throw UnknownFailure(data);
      }
      if (data is Map<String, dynamic>) {
        if (data.containsKey(_OrchestratorResponseKeys.error)) {
          // Safely convert to string and throw
          throw UnknownFailure(
            data[_OrchestratorResponseKeys.error]?.toString() ??
                'Unknown AI Error',
          );
        }

        // Extract the actual results mapping (handle GeneralDiscoveryResponse vs direct results)
        Map<String, dynamic> resultsMap = data;
        if (data.containsKey(_OrchestratorResponseKeys.data) &&
            data[_OrchestratorResponseKeys.data] is Map<String, dynamic>) {
          resultsMap =
              data[_OrchestratorResponseKeys.data] as Map<String, dynamic>;
        }

        // Map Genkit's 'movies' or 'media' key into the expected 'media' key for our DTO
        final safeJson = {
          'media':
              resultsMap[_OrchestratorResponseKeys.movies] ??
              resultsMap[_OrchestratorResponseKeys.media] ??
              [],
          'books': resultsMap[_OrchestratorResponseKeys.books] ?? [],
          'games': resultsMap[_OrchestratorResponseKeys.games] ?? [],
          'errors': resultsMap[_OrchestratorResponseKeys.errors],
        };

        return SearchAllResponseDto.fromJson(safeJson).toDomain();
      }
      throw const UnknownFailure('Unexpected backend response type');
    },
  );

  @override
  Future<List<Book>> searchBooks(String query, {String? language}) =>
      _post<List<Book>>(
        ApiConstants.searchBooks,
        CatalogSearchInputDto(query: query, language: language).toJson(),
        (data) => (data as List<dynamic>)
            .map((e) => BookDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );

  @override
  Future<List<Media>> searchMedia(String query, {String? language}) =>
      _post<List<Media>>(
        ApiConstants.searchMedia,
        CatalogSearchInputDto(query: query, language: language).toJson(),
        (data) => (data as List<dynamic>)
            .map((e) => MediaDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );

  @override
  Future<List<Game>> searchGames(String query, {String? language}) =>
      _post<List<Game>>(
        ApiConstants.searchGames,
        CatalogSearchInputDto(query: query, language: language).toJson(),
        (data) => (data as List<dynamic>)
            .map((e) => GameDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.badResponse => ServerFailure(
        statusCode: e.response?.statusCode ?? 0,
        message: e.response?.statusMessage,
      ),
      _ => UnknownFailure(e.message ?? 'Unknown error'),
    };
  }
}
