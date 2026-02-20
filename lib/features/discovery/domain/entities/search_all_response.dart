import 'book.dart';
import 'game.dart';
import 'media.dart';
import 'search_error.dart';

class SearchAllResponse {
  final List<Media> media;
  final List<Book> books;
  final List<Game> games;
  final List<SearchError>? errors;

  const SearchAllResponse({
    required this.media,
    required this.books,
    required this.games,
    this.errors,
  });
}
