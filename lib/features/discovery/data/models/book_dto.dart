import 'package:json_annotation/json_annotation.dart';

part 'book_dto.g.dart';

@JsonSerializable()
class BookDto {
  final String id;
  final String title;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn;
  final num? pageCount;
  final List<String>? categories;
  final BookImageLinksDto? imageLinks;
  final String? language;
  final String? previewLink;

  const BookDto({
    required this.id,
    required this.title,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.isbn,
    this.pageCount,
    this.categories,
    this.imageLinks,
    this.language,
    this.previewLink,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) =>
      _$BookDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookDtoToJson(this);
}

@JsonSerializable()
class BookImageLinksDto {
  final String? thumbnail;
  final String? smallThumbnail;

  const BookImageLinksDto({this.thumbnail, this.smallThumbnail});

  factory BookImageLinksDto.fromJson(Map<String, dynamic> json) =>
      _$BookImageLinksDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookImageLinksDtoToJson(this);
}
