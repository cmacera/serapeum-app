import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';

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
  Future<SearchAllResponse> searchAll(String query, {String? language});

  /// Search for books only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<Book>> searchBooks(String query, {String? language});

  /// Search for movies and TV shows only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<Media>> searchMedia(String query, {String? language});

  /// Search for video games only.
  ///
  /// Throws [NetworkFailure], [TimeoutFailure], [ServerFailure], or [UnknownFailure].
  Future<List<Game>> searchGames(String query, {String? language});
}
