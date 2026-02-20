// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDto _$BookDtoFromJson(Map<String, dynamic> json) => BookDto(
  id: json['id'] as String,
  title: json['title'] as String,
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  publisher: json['publisher'] as String?,
  publishedDate: json['publishedDate'] as String?,
  description: json['description'] as String?,
  isbn: json['isbn'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageLinks: json['imageLinks'] == null
      ? null
      : BookImageLinksDto.fromJson(json['imageLinks'] as Map<String, dynamic>),
  language: json['language'] as String?,
  previewLink: json['previewLink'] as String?,
);

Map<String, dynamic> _$BookDtoToJson(BookDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'authors': instance.authors,
  'publisher': instance.publisher,
  'publishedDate': instance.publishedDate,
  'description': instance.description,
  'isbn': instance.isbn,
  'pageCount': instance.pageCount,
  'categories': instance.categories,
  'imageLinks': instance.imageLinks?.toJson(),
  'language': instance.language,
  'previewLink': instance.previewLink,
};

BookImageLinksDto _$BookImageLinksDtoFromJson(Map<String, dynamic> json) =>
    BookImageLinksDto(
      thumbnail: json['thumbnail'] as String?,
      smallThumbnail: json['smallThumbnail'] as String?,
    );

Map<String, dynamic> _$BookImageLinksDtoToJson(BookImageLinksDto instance) =>
    <String, dynamic>{
      'thumbnail': instance.thumbnail,
      'smallThumbnail': instance.smallThumbnail,
    };
