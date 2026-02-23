import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/search_all_response.dart';
import '../../data/providers/discovery_providers.dart';
import '../../../../core/localization/locale_provider.dart';

part 'catalog_search_providers.g.dart';

@riverpod
Future<SearchAllResponse> searchAll(SearchAllRef ref, String query) async {
  if (query.isEmpty) {
    return const SearchAllResponse(media: [], books: [], games: []);
  }

  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);

  return await repository.searchAll(query, language: language);
}

@riverpod
Future<List<Book>> searchBooks(SearchBooksRef ref, String query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);

  return await repository.searchBooks(query, language: language);
}

@riverpod
Future<List<Media>> searchMedia(SearchMediaRef ref, String query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);

  return await repository.searchMedia(query, language: language);
}

@riverpod
Future<List<Game>> searchGames(SearchGamesRef ref, String query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);

  return await repository.searchGames(query, language: language);
}
