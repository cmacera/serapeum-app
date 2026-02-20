// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaDto _$MediaDtoFromJson(Map<String, dynamic> json) => MediaDto(
  id: (json['id'] as num).toInt(),
  mediaType: json['media_type'] as String,
  title: json['title'] as String?,
  name: json['name'] as String?,
  releaseDate: json['release_date'] as String?,
  posterPath: json['poster_path'] as String?,
  overview: json['overview'] as String?,
  voteAverage: json['vote_average'] as num?,
  popularity: json['popularity'] as num?,
);

Map<String, dynamic> _$MediaDtoToJson(MediaDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'name': instance.name,
  'media_type': instance.mediaType,
  'release_date': instance.releaseDate,
  'poster_path': instance.posterPath,
  'overview': instance.overview,
  'vote_average': instance.voteAverage,
  'popularity': instance.popularity,
};
