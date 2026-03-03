class AgeRating {
  final int category;
  final int rating;

  const AgeRating({required this.category, required this.rating});
}

class SimilarGame {
  final int id;
  final String name;

  const SimilarGame({required this.id, required this.name});
}

class Game {
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
  final List<AgeRating>? ageRatings;
  final List<SimilarGame>? similarGames;

  const Game({
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
}
