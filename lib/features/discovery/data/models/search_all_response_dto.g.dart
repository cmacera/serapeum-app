// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_all_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchAllResponseDto _$SearchAllResponseDtoFromJson(
  Map<String, dynamic> json,
) => SearchAllResponseDto(
  media: (json['media'] as List<dynamic>)
      .map((e) => MediaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  books: (json['books'] as List<dynamic>)
      .map((e) => BookDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  games: (json['games'] as List<dynamic>)
      .map((e) => GameDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>?)
      ?.map((e) => SearchErrorDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SearchAllResponseDtoToJson(
  SearchAllResponseDto instance,
) => <String, dynamic>{
  'media': instance.media.map((e) => e.toJson()).toList(),
  'books': instance.books.map((e) => e.toJson()).toList(),
  'games': instance.games.map((e) => e.toJson()).toList(),
  'errors': instance.errors?.map((e) => e.toJson()).toList(),
};

SearchErrorDto _$SearchErrorDtoFromJson(Map<String, dynamic> json) =>
    SearchErrorDto(
      source: json['source'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$SearchErrorDtoToJson(SearchErrorDto instance) =>
    <String, dynamic>{'source': instance.source, 'message': instance.message};
