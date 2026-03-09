import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LibrarySortOption { dateDesc, dateAsc, titleAsc, ratingDesc, byType }

final librarySortProvider = StateProvider<LibrarySortOption>(
  (ref) => LibrarySortOption.dateDesc,
);

final librarySearchQueryProvider = StateProvider<String>((ref) => '');
