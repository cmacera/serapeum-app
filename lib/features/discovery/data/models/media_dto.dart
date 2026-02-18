import 'package:json_annotation/json_annotation.dart';

part 'media_dto.g.dart';

@JsonSerializable()
class MediaDto {
  final num id;
  final String? title;
  final String? name;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  final String? overview;
  @JsonKey(name: 'vote_average')
  final num? voteAverage;
  final num? popularity;

  const MediaDto({
    required this.id,
    required this.mediaType,
    this.title,
    this.name,
    this.releaseDate,
    this.posterPath,
    this.overview,
    this.voteAverage,
    this.popularity,
  });

  factory MediaDto.fromJson(Map<String, dynamic> json) =>
      _$MediaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MediaDtoToJson(this);
}
