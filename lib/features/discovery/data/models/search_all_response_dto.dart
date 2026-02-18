import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/data/models/book_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/game_dto.dart';
import 'package:serapeum_app/features/discovery/data/models/media_dto.dart';

part 'search_all_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SearchAllResponseDto {
  final List<MediaDto> movies;
  final List<BookDto> books;
  final List<GameDto> games;
  final List<SearchErrorDto>? errors;

  const SearchAllResponseDto({
    required this.movies,
    required this.books,
    required this.games,
    this.errors,
  });

  factory SearchAllResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SearchAllResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchAllResponseDtoToJson(this);
}

@JsonSerializable()
class SearchErrorDto {
  final String source;
  final String message;

  const SearchErrorDto({required this.source, required this.message});

  factory SearchErrorDto.fromJson(Map<String, dynamic> json) =>
      _$SearchErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SearchErrorDtoToJson(this);
}
