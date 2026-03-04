class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });
}

class WatchProvider {
  final String logoPath;
  final int providerId;
  final String providerName;
  final int displayPriority;

  const WatchProvider({
    required this.logoPath,
    required this.providerId,
    required this.providerName,
    required this.displayPriority,
  });
}

class WatchProviderRegion {
  final String link;
  final List<WatchProvider>? flatrate;
  final List<WatchProvider>? rent;
  final List<WatchProvider>? buy;

  const WatchProviderRegion({
    required this.link,
    this.flatrate,
    this.rent,
    this.buy,
  });
}

class SeasonSummary {
  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? airDate;
  final String? posterPath;

  const SeasonSummary({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    this.airDate,
    this.posterPath,
  });
}

class Network {
  final int id;
  final String name;
  final String? logoPath;

  const Network({required this.id, required this.name, this.logoPath});
}

class Creator {
  final int id;
  final String name;
  final String? profilePath;

  const Creator({required this.id, required this.name, this.profilePath});
}

class MovieDetail {
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
  final List<String> genres;
  final List<CastMember> cast;
  final Map<String, WatchProviderRegion> watchProviders;
  final List<String> trailers;
  final String? certification;

  const MovieDetail({
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
    required this.watchProviders,
    this.trailers = const [],
    this.certification,
  });
}

class TvDetail {
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
  final List<int> episodeRunTime;
  final num? voteAverage;
  final num? voteCount;
  final num? popularity;
  final String? posterPath;
  final String? backdropPath;
  final List<String> genres;
  final List<CastMember> cast;
  final Map<String, WatchProviderRegion> watchProviders;
  final List<SeasonSummary> seasons;
  final List<Network> networks;
  final List<Creator> creators;
  final List<String> trailers;
  final String? certification;

  const TvDetail({
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
    required this.watchProviders,
    required this.seasons,
    required this.networks,
    required this.creators,
    this.trailers = const [],
    this.certification,
  });
}
