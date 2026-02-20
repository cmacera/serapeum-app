// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameDto _$GameDtoFromJson(Map<String, dynamic> json) => GameDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  summary: json['summary'] as String?,
  rating: json['rating'] as num?,
  aggregatedRating: json['aggregated_rating'] as num?,
  released: json['released'] as String?,
  coverUrl: json['cover_url'] as String?,
  platforms: (json['platforms'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
  developers: (json['developers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  publishers: (json['publishers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  gameType: (json['game_type'] as num?)?.toInt(),
);

Map<String, dynamic> _$GameDtoToJson(GameDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'summary': instance.summary,
  'rating': instance.rating,
  'aggregated_rating': instance.aggregatedRating,
  'released': instance.released,
  'cover_url': instance.coverUrl,
  'platforms': instance.platforms,
  'genres': instance.genres,
  'developers': instance.developers,
  'publishers': instance.publishers,
  'game_type': instance.gameType,
};
