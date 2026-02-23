import 'package:dio/dio.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/catalog_search_input_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_discover_repository.dart';

class _OrchestratorResponseKeys {
  static const String kind = 'kind';
  static const String data = 'data';

  /// The top-level error message when the entire flow fails.
  static const String error = 'error';

  /// Technical details or stack trace for the [error].
  static const String details = 'details';

  /// The conversational text synthesized by the AI (backend uses 'message').
  static const String message = 'message';
}

class _OrchestratorKind {
  static const String refusal = 'refusal';
  static const String searchResults = 'search_results';
  static const String discovery = 'discovery';
  static const String error = 'error';
}

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
  Future<OrchestratorResponse> orchestrate(
    String query, {
    String? language,
  }) => _post<OrchestratorResponse>(
    ApiConstants.orchestratorFlow,
    CatalogSearchInputDto(query: query, language: language).toJson(),
    (data) {
      // 1. Handle plain string fallback
      if (data is String) {
        return OrchestratorMessage(data);
      }

      // 2. Handle structured Map response
      if (data is Map<String, dynamic>) {
        final kind = data[_OrchestratorResponseKeys.kind] as String?;

        switch (kind) {
          case _OrchestratorKind.refusal:
            return OrchestratorMessage(
              data[_OrchestratorResponseKeys.message] as String? ?? '',
            );

          case _OrchestratorKind.searchResults:
          case _OrchestratorKind.discovery:
            final text =
                data[_OrchestratorResponseKeys.message] as String? ?? '';
            final resultsMap =
                data[_OrchestratorResponseKeys.data] as Map<String, dynamic>? ??
                {};
            final searchAllResponse = SearchAllResponseDto.fromJson(
              resultsMap,
            ).toDomain();

            return OrchestratorGeneral(text: text, data: searchAllResponse);

          case _OrchestratorKind.error:
            return OrchestratorError(
              error:
                  data[_OrchestratorResponseKeys.error]?.toString() ??
                  'Unknown error',
              details: data[_OrchestratorResponseKeys.details]?.toString(),
            );

          default:
            // Fallback for unexpected or missing 'kind'
            if (data.containsKey(_OrchestratorResponseKeys.error)) {
              return OrchestratorError(
                error: data[_OrchestratorResponseKeys.error].toString(),
                details: data[_OrchestratorResponseKeys.details]?.toString(),
              );
            }
            throw const UnknownFailure('Unexpected backend response structure');
        }
      }

      throw const UnknownFailure('Unexpected backend response type');
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
