import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';

/// Contract for pure catalog search operations.
abstract interface class ICatalogSearchRepository {
  /// Search across all media types in parallel.
  Future<SearchAllResponse> searchAll(String query, {String? language});

  /// Search for books only.
  Future<List<Book>> searchBooks(String query, {String? language});

  /// Search for movies and TV shows only.
  Future<List<Media>> searchMedia(String query, {String? language});

  /// Search for video games only.
  Future<List<Game>> searchGames(String query, {String? language});
}
