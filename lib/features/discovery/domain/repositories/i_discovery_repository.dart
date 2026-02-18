import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';

/// Contract for all discovery/search operations against the Serapeum API.
///
/// Implementations must be injectable and overridable for testing.
abstract interface class IDiscoveryRepository {
  /// Search across all media types (books, movies/TV, games) in parallel.
  Future<SearchAllResponseDto> searchAll(String query, {String? language});

  /// Search for books only.
  Future<List<BookDto>> searchBooks(String query, {String? language});

  /// Search for movies and TV shows only.
  Future<List<MediaDto>> searchMedia(String query, {String? language});

  /// Search for video games only.
  Future<List<GameDto>> searchGames(String query, {String? language});
}
