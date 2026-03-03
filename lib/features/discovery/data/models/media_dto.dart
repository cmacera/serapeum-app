import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';

part 'media_dto.g.dart';

/// Data transfer object for a movie or TV show from TMDB.
///
/// TMDB uses [title] for movies and [name] for TV shows.
/// Both fields can be null simultaneously in edge cases — consumers must guard
/// against this, e.g. `item.title ?? item.name ?? 'Unknown'`.
@JsonSerializable(fieldRename: FieldRename.snake)
class MediaDto {
  final int id;

  /// Movie title. Null for TV shows — use [name] instead.
  final String? title;

  /// TV show name. Null for movies — use [title] instead.
  final String? name;

  final String mediaType;
  final String? releaseDate;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final num? voteAverage;
  final num? popularity;
  final List<String>? genres;
  final List<int>? genreIds;
  final String? originalLanguage;

  const MediaDto({
    required this.id,
    required this.mediaType,
    this.title,
    this.name,
    this.releaseDate,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.voteAverage,
    this.popularity,
    this.genres,
    this.genreIds,
    this.originalLanguage,
  });

  factory MediaDto.fromJson(Map<String, dynamic> json) =>
      _$MediaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MediaDtoToJson(this);

  Media toDomain() => Media(
    id: id,
    title: title,
    name: name,
    mediaType: MediaType.values.firstWhere(
      (e) => e.name == mediaType,
      orElse: () => MediaType.unknown,
    ),
    releaseDate: releaseDate,
    posterPath: posterPath,
    backdropPath: backdropPath,
    overview: overview,
    voteAverage: voteAverage,
    popularity: popularity,
    genreIds: genreIds,
    originalLanguage: originalLanguage,
  );
}
