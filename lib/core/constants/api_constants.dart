class ApiConstants {
  ApiConstants._();

  /// The base URL for the Serapeum API.
  /// Initialized via --dart-define=BASE_URL=... at build time.
  static final String baseUrl = const String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Formatting
  static const String contentTypeJson = 'application/json';

  // TMDB
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String tmdbImageTierW500 = '/w500';
  static const String tmdbImageTierOriginal = '/original';

  // Hosts for AuthInterceptor
  static const String productionHost = 'serapeum.app';
  static const String localhostHost = 'localhost';
  static const String localhostIp = '127.0.0.1';
  static const String localhostIpV6 = '::1';
  static const String androidEmulatorHost = '10.0.2.2';

  // Endpoints
  static const String searchBooks = '/searchBooks';
  static const String searchMedia = '/searchMedia';
  static const String searchGames = '/searchGames';
  static const String searchAll = '/searchAll';
  static const String orchestratorFlow = '/orchestratorFlow';
}
