enum MediaType { movie, tv, unknown }

class Media {
  final int id;
  final String? title;
  final String? name;
  final MediaType mediaType;
  final String? releaseDate;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final num? voteAverage;
  final num? popularity;
  final List<int>? genreIds;
  final String? originalLanguage;

  const Media({
    required this.id,
    this.title,
    this.name,
    required this.mediaType,
    this.releaseDate,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.voteAverage,
    this.popularity,
    this.genreIds,
    this.originalLanguage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'name': name,
    'media_type': mediaType.name,
    'release_date': releaseDate,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'overview': overview,
    'vote_average': voteAverage,
    'popularity': popularity,
    'genre_ids': genreIds,
    'original_language': originalLanguage,
  };
}
