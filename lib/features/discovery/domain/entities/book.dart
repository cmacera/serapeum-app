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
  final num? averageRating;
  final String? maturityRating;

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
    this.averageRating,
    this.maturityRating,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'authors': authors,
    'publisher': publisher,
    'publishedDate': publishedDate,
    'description': description,
    'isbn': isbn,
    'pageCount': pageCount,
    'categories': categories,
    'imageLinks': imageLinks != null
        ? {
            'thumbnail': imageLinks!['thumbnail'],
            'smallThumbnail': imageLinks!['smallThumbnail'],
          }
        : null,
    'language': language,
    'previewLink': previewLink,
    'averageRating': averageRating,
    'maturityRating': maturityRating,
  };
}
