import 'book.dart';
import 'game.dart';
import 'media.dart';

/// A highlighted item returned by the orchestrator API in the `featured` field.
///
/// The API discriminates the subtype via a `type` string:
/// `'media'` → [FeaturedMedia], `'book'` → [FeaturedBook], `'game'` → [FeaturedGame].
///
/// Wire shape: `{ "type": "<kind>", "item": { ...fields } }`
sealed class FeaturedItem {
  const FeaturedItem();
  Map<String, dynamic> toJson();
}

class FeaturedMedia extends FeaturedItem {
  final Media media;
  const FeaturedMedia(this.media);

  @override
  Map<String, dynamic> toJson() => {'type': 'media', 'item': media.toJson()};
}

class FeaturedBook extends FeaturedItem {
  final Book book;
  const FeaturedBook(this.book);

  @override
  Map<String, dynamic> toJson() => {'type': 'book', 'item': book.toJson()};
}

class FeaturedGame extends FeaturedItem {
  final Game game;
  const FeaturedGame(this.game);

  @override
  Map<String, dynamic> toJson() => {'type': 'game', 'item': game.toJson()};
}
