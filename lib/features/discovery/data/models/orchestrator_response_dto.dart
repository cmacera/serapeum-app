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

  static const String _kindRefusal = 'refusal';
  static const String _kindSearchResults = 'search_results';
  static const String _kindDiscovery = 'discovery';
  static const String _kindError = 'error';

  /// Maps the raw [data] from the backend to a domain [OrchestratorResponse].
  static OrchestratorResponse mapToDomain(dynamic data) {
    // 1. Handle plain string fallback
    if (data is String) {
      return OrchestratorMessage(data);
    }

    // 2. Handle structured Map response
    if (data is Map<String, dynamic>) {
      final kind = data[_kKind] as String?;

      switch (kind) {
        case _kindRefusal:
          return OrchestratorMessage(data[_kMessage] as String? ?? '');

        case _kindSearchResults:
        case _kindDiscovery:
          final text = data[_kMessage] as String? ?? '';
          final resultsMap = data[_kData] as Map<String, dynamic>? ?? {};
          final searchAllResponse = SearchAllResponseDto.fromJson(
            resultsMap,
          ).toDomain();

          return OrchestratorGeneral(text: text, data: searchAllResponse);

        case _kindError:
          return OrchestratorError(
            error: data[_kError]?.toString() ?? 'Unknown error',
            details: data[_kDetails]?.toString(),
          );

        default:
          // Fallback for unexpected or missing 'kind'
          if (data.containsKey(_kError)) {
            return OrchestratorError(
              error: data[_kError]?.toString() ?? 'Unknown error',
              details: data[_kDetails]?.toString(),
            );
          }
          return OrchestratorMessage(data[_kMessage]?.toString() ?? '');
      }
    }

    return const OrchestratorMessage('Unexpected backend response type');
  }
}
