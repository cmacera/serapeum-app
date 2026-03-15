import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/featured_item.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_error.dart';

part 'search_all_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchAllResponseDto {
  @JsonKey(defaultValue: [])
  final List<MediaDto> media;
  @JsonKey(defaultValue: [])
  final List<BookDto> books;
  @JsonKey(defaultValue: [])
  final List<GameDto> games;
  final List<SearchErrorDto>? errors;
  final String? text;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final FeaturedItem? featured;

  const SearchAllResponseDto({
    this.media = const [],
    this.books = const [],
    this.games = const [],
    this.errors,
    this.text,
    this.featured,
  });

  factory SearchAllResponseDto.fromJson(Map<String, dynamic> json) {
    final dto = _$SearchAllResponseDtoFromJson(json);
    return SearchAllResponseDto(
      media: dto.media,
      books: dto.books,
      games: dto.games,
      errors: dto.errors,
      text: json['text'] as String?,
      featured: _parseFeatured(json['featured']),
    );
  }

  static const _kTypeMedia = 'media';
  static const _kTypeBook = 'book';
  static const _kTypeGame = 'game';

  // The featured object is AI-generated and may omit required fields (e.g. id).
  // Any parse failure returns null so the rest of the response is unaffected.
  static FeaturedItem? _parseFeatured(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final type = raw['type'] as String?;
    final item = raw['item'];
    if (item is! Map<String, dynamic>) return null;
    try {
      return switch (type) {
        _kTypeMedia => FeaturedMedia(MediaDto.fromJson(item).toDomain()),
        _kTypeBook => FeaturedBook(BookDto.fromJson(item).toDomain()),
        _kTypeGame => FeaturedGame(GameDto.fromJson(item).toDomain()),
        _ => null,
      };
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> toJson() => _$SearchAllResponseDtoToJson(this);

  SearchAllResponse toDomain() => SearchAllResponse(
    media: media.map((e) => e.toDomain()).toList(),
    books: books.map((e) => e.toDomain()).toList(),
    games: games.map((e) => e.toDomain()).toList(),
    errors: errors?.map((e) => e.toDomain()).toList(),
    text: text,
    featured: featured,
  );
}

@JsonSerializable()
class SearchErrorDto {
  final String source;
  final String message;

  const SearchErrorDto({required this.source, required this.message});

  factory SearchErrorDto.fromJson(Map<String, dynamic> json) =>
      _$SearchErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchErrorDtoToJson(this);

  SearchError toDomain() => SearchError(source: source, message: message);
}
