import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/features/discovery/domain/entities/paginated_result.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';

/// Contract for pure catalog search operations.
abstract interface class ICatalogSearchRepository {
  /// Search across all media types in parallel.
  Future<SearchAllResponse> searchAll(String query, {String? language});

  /// Search for books only.
  Future<PaginatedResult<Book>> searchBooks(
    String query, {
    String? language,
    int? page,
  });

  /// Search for movies and TV shows only.
  Future<PaginatedResult<Media>> searchMedia(
    String query, {
    String? language,
    int? page,
  });

  /// Search for video games only.
  Future<PaginatedResult<Game>> searchGames(
    String query, {
    String? language,
    int? page,
  });

  /// Fetch enriched movie detail by TMDB ID.
  Future<MovieDetail> getMovieDetail(
    int id, {
    String? language,
    String? region,
  });

  /// Fetch enriched TV show detail by TMDB ID.
  Future<TvDetail> getTvDetail(int id, {String? language, String? region});
}
