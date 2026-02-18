import 'package:json_annotation/json_annotation.dart';

part 'game_dto.g.dart';

@JsonSerializable()
class GameDto {
  final num id;
  final String name;
  final String? summary;
  final num? rating;
  @JsonKey(name: 'aggregated_rating')
  final num? aggregatedRating;
  final String? released;
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final List<String>? developers;
  final List<String>? publishers;
  @JsonKey(name: 'game_type')
  final num? gameType;

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
}
