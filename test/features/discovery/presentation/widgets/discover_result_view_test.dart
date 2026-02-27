import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/discover_query_provider.dart';
import 'package:serapeum_app/features/discovery/presentation/widgets/discover_result_view.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({required OrchestratorResponse? response}) {
    return ProviderScope(
      overrides: [
        discoverQueryProvider(
          'test query',
        ).overrideWith((ref) async => response),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: DiscoverResultView(query: 'test query')),
      ),
    );
  }

  group('DiscoverResultView Dynamic Tabs', () {
    testWidgets('shows no tabs when only one category has results', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final response = OrchestratorSelection(
        media: [
          const Media(id: 1, title: 'Test Movie', mediaType: MediaType.movie),
        ],
        books: const [],
        games: const [],
      );

      await tester.pumpWidget(createWidgetUnderTest(response: response));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverResultView)),
      )!;

      expect(find.text(l10n.filterAll), findsNothing);
      expect(find.text(l10n.filterMedia), findsNothing);
      expect(find.text(l10n.filterBooks), findsNothing);
      expect(find.text(l10n.filterGames), findsNothing);
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('shows tabs when two categories have results', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final response = OrchestratorSelection(
        media: [
          const Media(id: 1, title: 'Test Movie', mediaType: MediaType.movie),
        ],
        books: [const Book(id: '2', title: 'Test Book')],
        games: const [],
      );

      await tester.pumpWidget(createWidgetUnderTest(response: response));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverResultView)),
      )!;

      expect(find.text(l10n.filterAll), findsOneWidget);
      expect(find.text(l10n.filterMedia), findsOneWidget);
      expect(find.text(l10n.filterBooks), findsOneWidget);
      expect(find.text(l10n.filterGames), findsNothing);

      // Both results should be visible under "All"
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);
    });

    testWidgets('shows all tabs when all categories have results', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final response = OrchestratorSelection(
        media: [
          const Media(id: 1, title: 'Test Movie', mediaType: MediaType.movie),
        ],
        books: [const Book(id: '2', title: 'Test Book')],
        games: [const Game(id: 3, name: 'Test Game')],
      );

      await tester.pumpWidget(createWidgetUnderTest(response: response));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverResultView)),
      )!;

      expect(find.text(l10n.filterAll), findsOneWidget);
      expect(find.text(l10n.filterMedia), findsOneWidget);
      expect(find.text(l10n.filterBooks), findsOneWidget);
      expect(find.text(l10n.filterGames), findsOneWidget);
    });

    testWidgets('filters results when tapping tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final response = OrchestratorSelection(
        media: [
          const Media(id: 1, title: 'Test Movie', mediaType: MediaType.movie),
        ],
        books: [const Book(id: '2', title: 'Test Book')],
        games: [const Game(id: 3, name: 'Test Game')],
      );

      await tester.pumpWidget(createWidgetUnderTest(response: response));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverResultView)),
      )!;

      // Initially 'All' is selected, so all items should be visible
      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Game'), findsOneWidget);

      // Tap 'Media' tab
      await tester.tap(find.text(l10n.filterMedia));
      await tester.pumpAndSettle();

      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Book'), findsNothing);
      expect(find.text('Test Game'), findsNothing);

      // Tap 'Books' tab
      await tester.tap(find.text(l10n.filterBooks));
      await tester.pumpAndSettle();

      expect(find.text('Test Movie'), findsNothing);
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Game'), findsNothing);

      // Tap 'Games' tab
      await tester.tap(find.text(l10n.filterGames));
      await tester.pumpAndSettle();

      expect(find.text('Test Movie'), findsNothing);
      expect(find.text('Test Book'), findsNothing);
      expect(find.text('Test Game'), findsOneWidget);

      // Tap 'All' tab to restore
      await tester.tap(find.text(l10n.filterAll));
      await tester.pumpAndSettle();

      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Game'), findsOneWidget);
    });
  });
}
