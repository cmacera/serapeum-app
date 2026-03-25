import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';

/// DTO for the orchestrator flow response.
/// Handles the mapping from the structured (or raw string) backend response
/// to the domain [OrchestratorResponse] entities.
class OrchestratorResponseDto {
  static const String _kKind = 'kind';
  static const String _kData = 'data';
  static const String _kError = 'error';
  static const String _kDetails = 'details';
  static const String _kMessage = 'message';
  static const String _kTraceId = 'traceId';

  static const String _kindRefusal = 'refusal';
  static const String _kindSearchResults = 'search_results';
  static const String _kindDiscovery = 'discovery';
  static const String _kindSelection = 'orchestrator_selection';
  static const String _kindError = 'error';

  static const String _kUnknownError = 'Unknown error';
  static const String _kUnexpectedType = 'Unexpected backend response type';

  /// Maps the raw [data] from the backend to a domain [OrchestratorResponse].
  static OrchestratorResponse mapToDomain(dynamic data) {
    // 1. Handle plain string fallback
    if (data is String) {
      return OrchestratorMessage(data);
    }

    // 2. Handle structured Map response
    if (data is Map<String, dynamic>) {
      final kind = data[_kKind] as String?;
      final traceId = data[_kTraceId]?.toString();

      switch (kind) {
        case _kindRefusal:
          return OrchestratorMessage(
            data[_kMessage] as String? ?? '',
            traceId: traceId,
          );

        case _kindSearchResults:
        case _kindDiscovery:
          final text = data[_kMessage] as String? ?? '';

          // Safe check for the nested 'data' payload
          final rawResults = data[_kData];
          final resultsMap = rawResults is Map<String, dynamic>
              ? rawResults
              : <String, dynamic>{};

          final searchAllResponse = SearchAllResponseDto.fromJson(
            resultsMap,
          ).toDomain();

          return OrchestratorGeneral(
            text: text,
            data: searchAllResponse,
            traceId: traceId,
          );

        case _kindSelection:
          final rawResults = data[_kData];
          final resultsMap = rawResults is Map<String, dynamic>
              ? rawResults
              : <String, dynamic>{};

          final searchAllResponse = SearchAllResponseDto.fromJson(
            resultsMap,
          ).toDomain();

          return OrchestratorSelection(
            media: searchAllResponse.media,
            books: searchAllResponse.books,
            games: searchAllResponse.games,
            traceId: traceId,
          );

        case _kindError:
          return OrchestratorError(
            error: data[_kError]?.toString() ?? _kUnknownError,
            details: data[_kDetails]?.toString(),
            traceId: traceId,
          );

        default:
          // Fallback for unexpected or missing 'kind'
          if (data.containsKey(_kError)) {
            return OrchestratorError(
              error: data[_kError]?.toString() ?? _kUnknownError,
              details: data[_kDetails]?.toString(),
              traceId: traceId,
            );
          }
          return OrchestratorMessage(
            data[_kMessage]?.toString() ?? '',
            traceId: traceId,
          );
      }
    }

    return const OrchestratorMessage(_kUnexpectedType);
  }
}
