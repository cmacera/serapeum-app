class Media {
  final int id;
  final String? title;
  final String? name;
  final String mediaType;
  final String? releaseDate;
  final String? posterPath;
  final String? overview;
  final num? voteAverage;
  final num? popularity;

  const Media({
    required this.id,
    this.title,
    this.name,
    required this.mediaType,
    this.releaseDate,
    this.posterPath,
    this.overview,
    this.voteAverage,
    this.popularity,
  });
}
