class Book {
  final String id;
  final String title;
  final List<String>? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn;
  final int? pageCount;
  final List<String>? categories;
  final Map<String, String>? imageLinks;
  final String? language;
  final String? previewLink;

  const Book({
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
}
