import 'book.dart';
import 'featured_item.dart';
import 'game.dart';
import 'media.dart';
import 'search_error.dart';

class SearchAllResponse {
  final List<Media> media;
  final List<Book> books;
  final List<Game> games;
  final List<SearchError>? errors;
  final String? text;
  final FeaturedItem? featured;

  const SearchAllResponse({
    required this.media,
    required this.books,
    required this.games,
    this.errors,
    this.text,
    this.featured,
  });

  Map<String, dynamic> toJson() => {
    'media': media.map((e) => e.toJson()).toList(),
    'books': books.map((e) => e.toJson()).toList(),
    'games': games.map((e) => e.toJson()).toList(),
    'errors': errors
        ?.map((e) => {'source': e.source, 'message': e.message})
        .toList(),
    'text': text,
    if (featured != null) 'featured': featured!.toJson(),
  };
}
