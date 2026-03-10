class AgeRating {
  final String organization;
  final String rating;

  const AgeRating({required this.organization, required this.rating});

  factory AgeRating.fromJson(Map<String, dynamic> json) => AgeRating(
    organization: json['organization'] as String,
    rating: json['rating'] as String,
  );

  Map<String, dynamic> toJson() => {
    'organization': organization,
    'rating': rating,
  };
}

class SimilarGame {
  final int id;
  final String name;

  const SimilarGame({required this.id, required this.name});

  factory SimilarGame.fromJson(Map<String, dynamic> json) =>
      SimilarGame(id: json['id'] as int, name: json['name'] as String);

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

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: json['id'] as int,
    name: json['name'] as String,
    summary: json['summary'] as String?,
    rating: json['rating'] as num?,
    aggregatedRating: json['aggregated_rating'] as num?,
    released: json['released'] as String?,
    coverUrl: json['cover_url'] as String?,
    platforms: (json['platforms'] as List<dynamic>?)?.cast<String>(),
    genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
    developers: (json['developers'] as List<dynamic>?)?.cast<String>(),
    publishers: (json['publishers'] as List<dynamic>?)?.cast<String>(),
    gameType: json['game_type'] as int?,
    screenshots: (json['screenshots'] as List<dynamic>?)?.cast<String>(),
    videos: (json['videos'] as List<dynamic>?)?.cast<String>(),
    themes: (json['themes'] as List<dynamic>?)?.cast<String>(),
    gameModes: (json['game_modes'] as List<dynamic>?)?.cast<String>(),
    ageRatings: (json['age_ratings'] as List<dynamic>?)
        ?.map((e) => AgeRating.fromJson(e as Map<String, dynamic>))
        .toList(),
    similarGames: (json['similar_games'] as List<dynamic>?)
        ?.map((e) => SimilarGame.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

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
