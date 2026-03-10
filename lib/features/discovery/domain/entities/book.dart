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

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    authors: (json['authors'] as List<dynamic>?)?.cast<String>(),
    publisher: json['publisher'] as String?,
    publishedDate: json['publishedDate'] as String?,
    description: json['description'] as String?,
    isbn: json['isbn'] as String?,
    pageCount: json['pageCount'] as int?,
    categories: (json['categories'] as List<dynamic>?)?.cast<String>(),
    imageLinks: (json['imageLinks'] as Map<String, dynamic>?)
        ?.cast<String, String>(),
    language: json['language'] as String?,
    previewLink: json['previewLink'] as String?,
    averageRating: json['averageRating'] as num?,
    maturityRating: json['maturityRating'] as String?,
  );

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
