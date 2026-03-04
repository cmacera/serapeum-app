import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';

part 'game_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AgeRatingDto {
  final String organization;
  final String rating;

  const AgeRatingDto({required this.organization, required this.rating});

  factory AgeRatingDto.fromJson(Map<String, dynamic> json) =>
      _$AgeRatingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AgeRatingDtoToJson(this);

  AgeRating toDomain() => AgeRating(organization: organization, rating: rating);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SimilarGameDto {
  final int id;
  final String name;

  const SimilarGameDto({required this.id, required this.name});

  factory SimilarGameDto.fromJson(Map<String, dynamic> json) =>
      _$SimilarGameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SimilarGameDtoToJson(this);

  SimilarGame toDomain() => SimilarGame(id: id, name: name);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GameDto {
  final int id;
  final String name;
  final String? summary;
  final num? rating;
  final num? aggregatedRating;
  final String? released;
  final String? coverUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final List<String>? developers;
  final List<String>? publishers;
  final int? gameType;
  final List<String>? screenshots;
  final List<String>? videos;
  final List<String>? themes;
  final List<String>? gameModes;
  final List<AgeRatingDto>? ageRatings;
  final List<SimilarGameDto>? similarGames;

  const GameDto({
    required this.id,
    required this.name,
    this.summary,
    this.rating,
    this.aggregatedRating,
    this.released,
    this.coverUrl,
    this.platforms,
    this.genres,
    this.developers,
    this.publishers,
    this.gameType,
    this.screenshots,
    this.videos,
    this.themes,
    this.gameModes,
    this.ageRatings,
    this.similarGames,
  });

  factory GameDto.fromJson(Map<String, dynamic> json) =>
      _$GameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GameDtoToJson(this);

  Game toDomain() => Game(
    id: id,
    name: name,
    summary: summary,
    rating: rating,
    aggregatedRating: aggregatedRating,
    released: released,
    coverUrl: coverUrl,
    platforms: platforms,
    genres: genres,
    developers: developers,
    publishers: publishers,
    gameType: gameType,
    screenshots: screenshots,
    videos: videos,
    themes: themes,
    gameModes: gameModes,
    ageRatings: ageRatings?.map((e) => e.toDomain()).toList(),
    similarGames: similarGames?.map((e) => e.toDomain()).toList(),
  );
}
