/// API configuration constants for the Serapeum Orchestrator.
/// Covers SER-37: centralized API configuration.
abstract class ApiConstants {
  // Base URLs
  static const String devBaseUrl = 'http://localhost:3000';
  static const String prodBaseUrl = 'https://api.serapeum.app';

  // Endpoints
  static const String searchBooks = '/searchBooks';
  static const String searchMedia = '/searchMedia';
  static const String searchGames = '/searchGames';
  static const String searchAll = '/searchAll';
  static const String orchestratorFlow = '/orchestratorFlow';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Headers
  static const String contentTypeJson = 'application/json';
}
