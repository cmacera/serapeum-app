import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_error.dart';

part 'search_all_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchAllResponseDto {
  /// Contains both movies and TV shows.
  /// Disambiguate by checking [MediaDto.mediaType] (either 'movie' or 'tv').
  final List<MediaDto> media;
  final List<BookDto> books;
  final List<GameDto> games;
  final List<SearchErrorDto>? errors;

  const SearchAllResponseDto({
    required this.media,
    required this.books,
    required this.games,
    this.errors,
  });

  factory SearchAllResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchAllResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchAllResponseDtoToJson(this);

  SearchAllResponse toDomain() => SearchAllResponse(
    media: media.map((e) => e.toDomain()).toList(),
    books: books.map((e) => e.toDomain()).toList(),
    games: games.map((e) => e.toDomain()).toList(),
    errors: errors?.map((e) => e.toDomain()).toList(),
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
