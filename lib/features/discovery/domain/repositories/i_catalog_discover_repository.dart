import 'package:serapeum_app/features/discovery/domain/entities/feedback_score.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';

/// Contract for AI-driven discovery operations.
abstract interface class ICatalogDiscoverRepository {
  /// Uses the AI orchestrator to process natural language queries.
  Future<OrchestratorResponse> orchestrate(String query, {String? language});

  /// Submits a [FeedbackScore] rating for a specific orchestrator response,
  /// identified by [traceId].
  Future<void> submitFeedback({
    required String traceId,
    required FeedbackScore score,
  });
}
