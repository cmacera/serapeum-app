import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';

part 'game_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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
  );
}
