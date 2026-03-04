import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';

part 'media_detail_dto.g.dart';

/// Safely parses the `watch_providers` JSON field into a DTO map.
/// Skips entries where the value is null or not a JSON object.
Map<String, WatchProviderRegionDto> _parseWatchProviders(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, WatchProviderRegionDto>{};
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      result[entry.key as String] = WatchProviderRegionDto.fromJson(value);
    }
  }
  return result;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CastMemberDto {
  final int id;
  final String name;
  @JsonKey(defaultValue: '')
  final String character;
  final String? profilePath;

  const CastMemberDto({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMemberDto.fromJson(Map<String, dynamic> json) =>
      _$CastMemberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CastMemberDtoToJson(this);

  CastMember toDomain() => CastMember(
    id: id,
    name: name,
    character: character,
    profilePath: profilePath,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class WatchProviderDto {
  final String logoPath;
  final int providerId;
  final String providerName;
  final int displayPriority;

  const WatchProviderDto({
    required this.logoPath,
    required this.providerId,
    required this.providerName,
    required this.displayPriority,
  });

  factory WatchProviderDto.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchProviderDtoToJson(this);

  WatchProvider toDomain() => WatchProvider(
    logoPath: logoPath,
    providerId: providerId,
    providerName: providerName,
    displayPriority: displayPriority,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class WatchProviderRegionDto {
  final String link;
  final List<WatchProviderDto>? flatrate;
  final List<WatchProviderDto>? rent;
  final List<WatchProviderDto>? buy;

  const WatchProviderRegionDto({
    required this.link,
    this.flatrate,
    this.rent,
    this.buy,
  });

  factory WatchProviderRegionDto.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderRegionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchProviderRegionDtoToJson(this);

  WatchProviderRegion toDomain() => WatchProviderRegion(
    link: link,
    flatrate: flatrate?.map((e) => e.toDomain()).toList(),
    rent: rent?.map((e) => e.toDomain()).toList(),
    buy: buy?.map((e) => e.toDomain()).toList(),
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SeasonSummaryDto {
  @JsonKey(defaultValue: 0)
  final int seasonNumber;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 0)
  final int episodeCount;
  final String? airDate;
  final String? posterPath;

  const SeasonSummaryDto({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.airDate,
    this.posterPath,
  });

  factory SeasonSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SeasonSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonSummaryDtoToJson(this);

  SeasonSummary toDomain() => SeasonSummary(
    seasonNumber: seasonNumber,
    name: name,
    episodeCount: episodeCount,
    airDate: airDate,
    posterPath: posterPath,
  );
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NetworkDto {
  final int id;
  final String name;
  final String? logoPath;

  const NetworkDto({required this.id, required this.name, this.logoPath});

  factory NetworkDto.fromJson(Map<String, dynamic> json) =>
      _$NetworkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkDtoToJson(this);

  Network toDomain() => Network(id: id, name: name, logoPath: logoPath);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreatorDto {
  final int id;
  final String name;
  final String? profilePath;

  const CreatorDto({required this.id, required this.name, this.profilePath});

  factory CreatorDto.fromJson(Map<String, dynamic> json) =>
      _$CreatorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatorDtoToJson(this);

  Creator toDomain() => Creator(id: id, name: name, profilePath: profilePath);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MovieDetailDto {
  final int id;
  final String title;
  final String originalTitle;
  final String? overview;
  final String? tagline;
  final String? releaseDate;
  final String? status;
  final String? originalLanguage;
  final int? runtime;
  final num? budget;
  final num? revenue;
  final num? voteAverage;
  final num? voteCount;
  final num? popularity;
  final String? posterPath;
  final String? backdropPath;
  @JsonKey(defaultValue: [])
  final List<String> genres;
  @JsonKey(defaultValue: [])
  final List<CastMemberDto> cast;
  // watch_providers is Map<regionCode, WatchProviderRegionDto> — parsed manually
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, WatchProviderRegionDto> watchProviders;

  const MovieDetailDto({
    required this.id,
    required this.title,
    required this.originalTitle,
    this.overview,
    this.tagline,
    this.releaseDate,
    this.status,
    this.originalLanguage,
    this.runtime,
    this.budget,
    this.revenue,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.posterPath,
    this.backdropPath,
    required this.genres,
    required this.cast,
    this.watchProviders = const {},
  });

  factory MovieDetailDto.fromJson(Map<String, dynamic> json) {
    final base = _$MovieDetailDtoFromJson(json);
    final providers = _parseWatchProviders(json['watch_providers']);
    return MovieDetailDto(
      id: base.id,
      title: base.title,
      originalTitle: base.originalTitle,
      overview: base.overview,
      tagline: base.tagline,
      releaseDate: base.releaseDate,
      status: base.status,
      originalLanguage: base.originalLanguage,
      runtime: base.runtime,
      budget: base.budget,
      revenue: base.revenue,
      voteAverage: base.voteAverage,
      voteCount: base.voteCount,
      popularity: base.popularity,
      posterPath: base.posterPath,
      backdropPath: base.backdropPath,
      genres: base.genres,
      cast: base.cast,
      watchProviders: providers,
    );
  }

  Map<String, dynamic> toJson() => _$MovieDetailDtoToJson(this);

  MovieDetail toDomain() => MovieDetail(
    id: id,
    title: title,
    originalTitle: originalTitle,
    overview: overview,
    tagline: tagline,
    releaseDate: releaseDate,
    status: status,
    originalLanguage: originalLanguage,
    runtime: runtime,
    budget: budget,
    revenue: revenue,
    voteAverage: voteAverage,
    voteCount: voteCount,
    popularity: popularity,
    posterPath: posterPath,
    backdropPath: backdropPath,
    genres: genres,
    cast: cast.map((e) => e.toDomain()).toList(),
    watchProviders: watchProviders.map(
      (key, value) => MapEntry(key, value.toDomain()),
    ),
  );
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TvDetailDto {
  final int id;
  final String name;
  final String originalName;
  final String? overview;
  final String? tagline;
  final String? firstAirDate;
  final String? lastAirDate;
  final String? status;
  final String? originalLanguage;
  final int? seasonsCount;
  final int? episodesCount;
  @JsonKey(defaultValue: [])
  final List<int> episodeRunTime;
  final num? voteAverage;
  final num? voteCount;
  final num? popularity;
  final String? posterPath;
  final String? backdropPath;
  @JsonKey(defaultValue: [])
  final List<String> genres;
  @JsonKey(defaultValue: [])
  final List<CastMemberDto> cast;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, WatchProviderRegionDto> watchProviders;
  @JsonKey(defaultValue: [])
  final List<SeasonSummaryDto> seasons;
  @JsonKey(defaultValue: [])
  final List<NetworkDto> networks;
  @JsonKey(defaultValue: [])
  final List<CreatorDto> creators;

  const TvDetailDto({
    required this.id,
    required this.name,
    required this.originalName,
    this.overview,
    this.tagline,
    this.firstAirDate,
    this.lastAirDate,
    this.status,
    this.originalLanguage,
    this.seasonsCount,
    this.episodesCount,
    required this.episodeRunTime,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.posterPath,
    this.backdropPath,
    required this.genres,
    required this.cast,
    this.watchProviders = const {},
    required this.seasons,
    required this.networks,
    required this.creators,
  });

  factory TvDetailDto.fromJson(Map<String, dynamic> json) {
    final base = _$TvDetailDtoFromJson(json);
    final providers = _parseWatchProviders(json['watch_providers']);
    return TvDetailDto(
      id: base.id,
      name: base.name,
      originalName: base.originalName,
      overview: base.overview,
      tagline: base.tagline,
      firstAirDate: base.firstAirDate,
      lastAirDate: base.lastAirDate,
      status: base.status,
      originalLanguage: base.originalLanguage,
      seasonsCount: base.seasonsCount,
      episodesCount: base.episodesCount,
      episodeRunTime: base.episodeRunTime,
      voteAverage: base.voteAverage,
      voteCount: base.voteCount,
      popularity: base.popularity,
      posterPath: base.posterPath,
      backdropPath: base.backdropPath,
      genres: base.genres,
      cast: base.cast,
      watchProviders: providers,
      seasons: base.seasons,
      networks: base.networks,
      creators: base.creators,
    );
  }

  Map<String, dynamic> toJson() => _$TvDetailDtoToJson(this);

  TvDetail toDomain() => TvDetail(
    id: id,
    name: name,
    originalName: originalName,
    overview: overview,
    tagline: tagline,
    firstAirDate: firstAirDate,
    lastAirDate: lastAirDate,
    status: status,
    originalLanguage: originalLanguage,
    seasonsCount: seasonsCount,
    episodesCount: episodesCount,
    episodeRunTime: episodeRunTime,
    voteAverage: voteAverage,
    voteCount: voteCount,
    popularity: popularity,
    posterPath: posterPath,
    backdropPath: backdropPath,
    genres: genres,
    cast: cast.map((e) => e.toDomain()).toList(),
    watchProviders: watchProviders.map(
      (key, value) => MapEntry(key, value.toDomain()),
    ),
    seasons: seasons.map((e) => e.toDomain()).toList(),
    networks: networks.map((e) => e.toDomain()).toList(),
    creators: creators.map((e) => e.toDomain()).toList(),
  );
}
