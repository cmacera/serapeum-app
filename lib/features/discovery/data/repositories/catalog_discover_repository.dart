import 'package:dio/dio.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/catalog_search_input_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/orchestrator_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_discover_repository.dart';

/// Concrete implementation of [ICatalogDiscoverRepository] using Dio.
class CatalogDiscoverRepository implements ICatalogDiscoverRepository {
  final Dio _dio;

  const CatalogDiscoverRepository(this._dio);

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
  Future<OrchestratorResponse> orchestrate(String query, {String? language}) =>
      _post<OrchestratorResponse>(
        ApiConstants.orchestratorFlow,
        CatalogSearchInputDto(query: query, language: language).toJson(),
        (data) => OrchestratorResponseDto.mapToDomain(data),
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
