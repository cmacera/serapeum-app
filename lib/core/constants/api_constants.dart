/// API configuration constants for the Serapeum Orchestrator.
/// Covers SER-37: centralized API configuration.
abstract class ApiConstants {
  // Endpoints
  static const String searchBooks = '/searchBooks';
  static const String searchMedia = '/searchMedia';
  static const String searchGames = '/searchGames';
  static const String searchAll = '/searchAll';
  static const String orchestratorFlow = '/orchestratorFlow';

  // Timeouts (Increased for slow orchestrator AI requests)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 90);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';

  // Images
  static const String kTmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}
