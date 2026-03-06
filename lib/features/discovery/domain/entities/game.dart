class AgeRating {
  final String organization;
  final String rating;

  const AgeRating({required this.organization, required this.rating});

  Map<String, dynamic> toJson() => {
    'organization': organization,
    'rating': rating,
  };
}

class SimilarGame {
  final int id;
  final String name;

  const SimilarGame({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'summary': summary,
    'rating': rating,
    'aggregated_rating': aggregatedRating,
    'released': released,
    'cover_url': coverUrl,
    'platforms': platforms,
    'genres': genres,
    'developers': developers,
    'publishers': publishers,
    'game_type': gameType,
    'screenshots': screenshots,
    'videos': videos,
    'themes': themes,
    'game_modes': gameModes,
    'age_ratings': ageRatings?.map((e) => e.toJson()).toList(),
    'similar_games': similarGames?.map((e) => e.toJson()).toList(),
  };
}
