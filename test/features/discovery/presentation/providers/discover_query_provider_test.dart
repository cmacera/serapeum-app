import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serapeum_app/core/localization/locale_provider.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_discover_repository.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/discover_query_provider.dart';
import 'package:serapeum_app/features/discovery/data/providers/discovery_providers.dart';

class MockCatalogDiscoverRepository extends Mock
    implements ICatalogDiscoverRepository {}

void main() {
  late MockCatalogDiscoverRepository mockRepository;

  setUp(() {
    mockRepository = MockCatalogDiscoverRepository();
  });

  ProviderContainer createContainer({List<Override> overrides = const []}) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return container;
  }

  group('discoverQuery', () {
    test('should return null when query is empty', () async {
      final container = createContainer();
      final result = await container.read(discoverQueryProvider('').future);
      expect(result, isNull);
    });

    test(
      'should call repository with device language from localeProvider',
      () async {
        // arrange
        const testQuery = 'hello';
        const testLanguage = 'es';
        final testResponse = OrchestratorMessage('Hola');

        when(
          () => mockRepository.orchestrate(testQuery, language: testLanguage),
        ).thenAnswer((_) async => testResponse);

        final container = createContainer(
          overrides: [
            catalogDiscoverRepositoryProvider.overrideWithValue(mockRepository),
            localeProvider.overrideWithValue(testLanguage),
          ],
        );

        // act
        final result = await container.read(
          discoverQueryProvider(testQuery).future,
        );

        // assert
        expect(result, testResponse);
        verify(
          () => mockRepository.orchestrate(testQuery, language: testLanguage),
        ).called(1);
      },
    );

    test('should default language when no override is provided', () async {
      // arrange
      const testQuery = 'test';
      final testResponse = OrchestratorMessage('Response');

      // We expect 'en' as default if we don't override the localeProvider
      // (assuming current system locale during test is 'en' or handled by platform)
      // For deterministic testing, we use 'en' here.
      when(
        () => mockRepository.orchestrate(testQuery, language: 'en'),
      ).thenAnswer((_) async => testResponse);

      final container = createContainer(
        overrides: [
          catalogDiscoverRepositoryProvider.overrideWithValue(mockRepository),
          localeProvider.overrideWithValue('en'),
        ],
      );

      // act
      await container.read(discoverQueryProvider(testQuery).future);

      // assert
      verify(
        () => mockRepository.orchestrate(testQuery, language: 'en'),
      ).called(1);
    });
  });
}
