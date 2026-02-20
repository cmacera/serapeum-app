import 'package:json_annotation/json_annotation.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';

part 'book_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class BookDto {
  final String id;
  final String title;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn;
  final int? pageCount;
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

  Book toDomain() {
    final Map<String, String> links = {};
    if (imageLinks?.thumbnail != null) {
      links['thumbnail'] = imageLinks!.thumbnail!;
    }
    if (imageLinks?.smallThumbnail != null) {
      links['smallThumbnail'] = imageLinks!.smallThumbnail!;
    }

    return Book(
      id: id,
      title: title,
      authors: authors,
      publisher: publisher,
      publishedDate: publishedDate,
      description: description,
      isbn: isbn,
      pageCount: pageCount,
      categories: categories,
      imageLinks: links.isNotEmpty ? links : null,
      language: language,
      previewLink: previewLink,
    );
  }
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
