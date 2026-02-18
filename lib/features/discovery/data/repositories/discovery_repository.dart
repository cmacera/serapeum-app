import 'package:dio/dio.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_discovery_repository.dart';

/// Concrete implementation of [IDiscoveryRepository] using Dio.
class DiscoveryRepository implements IDiscoveryRepository {
  final Dio _dio;

  const DiscoveryRepository(this._dio);

  @override
  Future<SearchAllResponseDto> searchAll(
    String query, {
    String? language,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.searchAll,
        data: CatalogSearchInputDto(query: query, language: language).toJson(),
      );
      return SearchAllResponseDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<BookDto>> searchBooks(String query, {String? language}) async {
    try {
      final response = await _dio.post<List<dynamic>>(
        ApiConstants.searchBooks,
        data: CatalogSearchInputDto(query: query, language: language).toJson(),
      );
      return response.data!
          .map((e) => BookDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<MediaDto>> searchMedia(String query, {String? language}) async {
    try {
      final response = await _dio.post<List<dynamic>>(
        ApiConstants.searchMedia,
        data: CatalogSearchInputDto(query: query, language: language).toJson(),
      );
      return response.data!
          .map((e) => MediaDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<GameDto>> searchGames(String query, {String? language}) async {
    try {
      final response = await _dio.post<List<dynamic>>(
        ApiConstants.searchGames,
        data: CatalogSearchInputDto(query: query, language: language).toJson(),
      );
      return response.data!
          .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Failure _mapDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout => const NetworkFailure(),
      DioExceptionType.badResponse => ServerFailure(
        statusCode: e.response?.statusCode ?? 0,
        message: e.response?.statusMessage,
      ),
      _ => UnknownFailure(e.message ?? 'Unknown error'),
    };
  }
}
