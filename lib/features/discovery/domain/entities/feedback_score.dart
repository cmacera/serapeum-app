/// Represents a binary quality rating for an orchestrator response.
///
/// Maps to the API score field: [up] → 1 (positive), [down] → 0 (negative).
enum FeedbackScore {
  up,
  down;

  /// The integer value expected by the `/feedback` endpoint.
  int get value => this == FeedbackScore.up ? 1 : 0;
}
