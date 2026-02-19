import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';

/// Contract for all discovery/search operations against the Serapeum API.
///
/// Implementations must be injectable and overridable for testing.
abstract interface class IDiscoveryRepository {
  /// Search across all media types (books, movies/TV, games) in parallel.
  ///
  /// Throws [NetworkFailure] on connection issues.
  /// Throws [TimeoutFailure] on send/receive timeouts.
  /// Throws [ServerFailure] on non-2xx HTTP responses.
  /// Throws [UnknownFailure] for unexpected errors (e.g. JSON parse failures).
  Future<SearchAllResponseDto> searchAll(String query, {String? language});

  /// Search for books only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<BookDto>> searchBooks(String query, {String? language});

  /// Search for movies and TV shows only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<MediaDto>> searchMedia(String query, {String? language});

  /// Search for video games only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<GameDto>> searchGames(String query, {String? language});
}
