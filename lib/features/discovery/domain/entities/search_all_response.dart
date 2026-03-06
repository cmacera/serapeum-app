import 'book.dart';
import 'game.dart';
import 'media.dart';
import 'search_error.dart';

class SearchAllResponse {
  final List<Media> media;
  final List<Book> books;
  final List<Game> games;
  final List<SearchError>? errors;
  final String? text;

  const SearchAllResponse({
    required this.media,
    required this.books,
    required this.games,
    this.errors,
    this.text,
  });

  Map<String, dynamic> toJson() => {
    'media': media.map((e) => e.toJson()).toList(),
    'books': books.map((e) => e.toJson()).toList(),
    'games': games.map((e) => e.toJson()).toList(),
  };
}
