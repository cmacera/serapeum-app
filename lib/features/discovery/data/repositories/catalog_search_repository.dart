import 'package:dio/dio.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/catalog_search_input_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_detail_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/features/discovery/domain/entities/paginated_result.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_search_repository.dart';

/// Concrete implementation of [ICatalogSearchRepository] using Dio.
class CatalogSearchRepository implements ICatalogSearchRepository {
  final Dio _dio;

  const CatalogSearchRepository(this._dio);

  Future<T> _post<T>(
    String path,
    dynamic dataPayload,
    T Function(dynamic data) converter,
  ) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: {'data': dataPayload},
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic> ||
          !responseData.containsKey('result')) {
        throw const UnknownFailure('Invalid or missing result from server');
      }

      final result = responseData['result'];
      if (result == null) {
        throw const UnknownFailure('Empty result from server');
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
  Future<SearchAllResponse> searchAll(String query, {String? language}) =>
      _post<SearchAllResponse>(
        ApiConstants.searchAll,
        CatalogSearchInputDto(query: query, language: language).toJson(),
        (data) {
          if (data is Map<String, dynamic>) {
            return SearchAllResponseDto.fromJson(data).toDomain();
          }
          throw const UnknownFailure('Expected Map for searchAll response');
        },
      );

  PaginatedResult<T> _parsePaginated<T>(
    dynamic data,
    String endpoint,
    T Function(Map<String, dynamic>) parse,
  ) {
    if (data is! Map<String, dynamic>) {
      throw UnknownFailure('Expected Map for $endpoint response');
    }
    final rawResults = data['results'];
    if (rawResults is! List) {
      throw UnknownFailure('$endpoint: "results" must be a List');
    }
    final rawPage = data['page'];
    if (rawPage is! int) {
      throw UnknownFailure('$endpoint: "page" must be an int');
    }
    final rawHasMore = data['hasMore'];
    if (rawHasMore is! bool) {
      throw UnknownFailure('$endpoint: "hasMore" must be a bool');
    }
    final rawTotal = data['total'];
    if (rawTotal != null && rawTotal is! int) {
      throw UnknownFailure('$endpoint: "total" must be an int or null');
    }
    return PaginatedResult(
      results: rawResults.map((e) {
        if (e is! Map<String, dynamic>) {
          throw UnknownFailure('$endpoint: result item must be a Map');
        }
        return parse(e);
      }).toList(),
      page: rawPage,
      hasMore: rawHasMore,
      total: rawTotal as int?,
    );
  }

  @override
  Future<PaginatedResult<Book>> searchBooks(
    String query, {
    String? language,
    int? page,
  }) => _post(
    ApiConstants.searchBooks,
    CatalogSearchInputDto(
      query: query,
      language: language,
      page: page,
    ).toJson(),
    (data) => _parsePaginated(
      data,
      ApiConstants.searchBooks,
      (e) => BookDto.fromJson(e).toDomain(),
    ),
  );

  @override
  Future<PaginatedResult<Media>> searchMedia(
    String query, {
    String? language,
    int? page,
  }) => _post(
    ApiConstants.searchMedia,
    CatalogSearchInputDto(
      query: query,
      language: language,
      page: page,
    ).toJson(),
    (data) => _parsePaginated(
      data,
      ApiConstants.searchMedia,
      (e) => MediaDto.fromJson(e).toDomain(),
    ),
  );

  @override
  Future<PaginatedResult<Game>> searchGames(
    String query, {
    String? language,
    int? page,
  }) => _post(
    ApiConstants.searchGames,
    CatalogSearchInputDto(
      query: query,
      language: language,
      page: page,
    ).toJson(),
    (data) => _parsePaginated(
      data,
      ApiConstants.searchGames,
      (e) => GameDto.fromJson(e).toDomain(),
    ),
  );

  @override
  Future<MovieDetail> getMovieDetail(
    int id, {
    String? language,
    String? region,
  }) => _post<MovieDetail>(
    ApiConstants.getMovieDetail,
    {'id': id, 'language': ?language, 'region': ?region},
    (data) {
      if (data is Map<String, dynamic>) {
        return MovieDetailDto.fromJson(data).toDomain();
      }
      throw const UnknownFailure('Expected Map for getMovieDetail response');
    },
  );

  @override
  Future<TvDetail> getTvDetail(int id, {String? language, String? region}) =>
      _post<TvDetail>(
        ApiConstants.getTvDetail,
        {'id': id, 'language': ?language, 'region': ?region},
        (data) {
          if (data is Map<String, dynamic>) {
            return TvDetailDto.fromJson(data).toDomain();
          }
          throw const UnknownFailure('Expected Map for getTvDetail response');
        },
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
