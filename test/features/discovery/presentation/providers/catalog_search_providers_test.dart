import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serapeum_app/core/localization/locale_provider.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/paginated_result.dart';
import 'package:serapeum_app/features/discovery/domain/entities/search_all_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_search_repository.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/catalog_search_providers.dart';
import 'package:serapeum_app/features/discovery/data/providers/discovery_providers.dart';

class MockCatalogSearchRepository extends Mock
    implements ICatalogSearchRepository {}

void main() {
  late MockCatalogSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockCatalogSearchRepository();
  });

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  group('CatalogSearchProviders', () {
    const testQuery = 'test';
    const testLanguage = 'fr';

    test('searchAll should propagate language', () async {
      final testResponse = SearchAllResponse(media: [], books: [], games: []);
      when(
        () => mockRepository.searchAll(testQuery, language: testLanguage),
      ).thenAnswer((_) async => testResponse);

      final container = createContainer(
        overrides: [
          catalogSearchRepositoryProvider.overrideWithValue(mockRepository),
          localeProvider.overrideWithValue(testLanguage),
        ],
      );

      final result = await container.read(searchAllProvider(testQuery).future);
      expect(result, testResponse);
      verify(
        () => mockRepository.searchAll(testQuery, language: testLanguage),
      ).called(1);
    });

    test('searchBooks should propagate language', () async {
      final pagedResponse = PaginatedResult<Book>(
        results: [],
        page: 1,
        hasMore: false,
      );
      when(
        () => mockRepository.searchBooks(testQuery, language: testLanguage),
      ).thenAnswer((_) async => pagedResponse);

      final container = createContainer(
        overrides: [
          catalogSearchRepositoryProvider.overrideWithValue(mockRepository),
          localeProvider.overrideWithValue(testLanguage),
        ],
      );

      final result = await container.read(
        searchBooksProvider(testQuery).future,
      );
      expect(result, pagedResponse.results);
      verify(
        () => mockRepository.searchBooks(testQuery, language: testLanguage),
      ).called(1);
    });

    test('searchMedia should propagate language', () async {
      final pagedResponse = PaginatedResult<Media>(
        results: [],
        page: 1,
        hasMore: false,
      );
      when(
        () => mockRepository.searchMedia(testQuery, language: testLanguage),
      ).thenAnswer((_) async => pagedResponse);

      final container = createContainer(
        overrides: [
          catalogSearchRepositoryProvider.overrideWithValue(mockRepository),
          localeProvider.overrideWithValue(testLanguage),
        ],
      );

      final result = await container.read(
        searchMediaProvider(testQuery).future,
      );
      expect(result, pagedResponse.results);
      verify(
        () => mockRepository.searchMedia(testQuery, language: testLanguage),
      ).called(1);
    });

    test('searchGames should propagate language', () async {
      final pagedResponse = PaginatedResult<Game>(
        results: [],
        page: 1,
        hasMore: false,
      );
      when(
        () => mockRepository.searchGames(testQuery, language: testLanguage),
      ).thenAnswer((_) async => pagedResponse);

      final container = createContainer(
        overrides: [
          catalogSearchRepositoryProvider.overrideWithValue(mockRepository),
          localeProvider.overrideWithValue(testLanguage),
        ],
      );

      final result = await container.read(
        searchGamesProvider(testQuery).future,
      );
      expect(result, pagedResponse.results);
      verify(
        () => mockRepository.searchGames(testQuery, language: testLanguage),
      ).called(1);
    });
  });
}
