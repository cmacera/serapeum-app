import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/presentation/widgets/discover_detail_modal.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Object entity) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: DiscoverDetailModal(entity: entity)),
    );
  }

  group('DiscoverDetailModal', () {
    testWidgets('renders Media entity correctly', (WidgetTester tester) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
        releaseDate: '2010-07-16',
        voteAverage: 8.8,
        overview: 'A thief who steals corporate secrets...',
      );

      await tester.pumpWidget(createWidgetUnderTest(media));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('2010'), findsOneWidget);
      expect(find.text('8.8'), findsOneWidget);
      expect(find.text(l10n.detailSynopsis), findsOneWidget);
      expect(
        find.text('A thief who steals corporate secrets...'),
        findsOneWidget,
      );
    });

    testWidgets('renders Book entity correctly', (WidgetTester tester) async {
      const book = Book(
        id: '1',
        title: '1984',
        authors: ['George Orwell'],
        publisher: 'Secker & Warburg',
        publishedDate: '1949-06-08',
        pageCount: 328,
        description: 'Among the seminal texts of the 20th century...',
        isbn: '9780451524935',
      );

      await tester.pumpWidget(createWidgetUnderTest(book));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('1984'), findsOneWidget);
      expect(find.text('1949'), findsOneWidget);
      expect(find.text('328 p.'), findsOneWidget);
      expect(find.text(l10n.detailSynopsis), findsOneWidget);
      expect(
        find.text('Among the seminal texts of the 20th century...'),
        findsOneWidget,
      );
      expect(find.text(l10n.detailPublishingInfo), findsOneWidget);
      expect(
        find.textContaining('${l10n.detailAuthors}: George Orwell'),
        findsOneWidget,
      );
      expect(
        find.textContaining('${l10n.detailPublisher}: Secker & Warburg'),
        findsOneWidget,
      );
      expect(find.textContaining('ISBN: 9780451524935'), findsOneWidget);
    });

    testWidgets('renders Game entity correctly', (WidgetTester tester) async {
      const game = Game(
        id: 1,
        name: 'The Witcher 3: Wild Hunt',
        released: '2015-05-18',
        rating: 4.67,
        summary:
            'A story-driven, next-generation open world role-playing game...',
        platforms: ['PC', 'PlayStation 4', 'Xbox One'],
        genres: ['Action', 'RPG'],
        developers: ['CD PROJEKT RED'],
      );

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('The Witcher 3: Wild Hunt'), findsOneWidget);
      expect(find.text('2015'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text(l10n.detailSynopsis), findsOneWidget);
      expect(
        find.text(
          'A story-driven, next-generation open world role-playing game...',
        ),
        findsOneWidget,
      );
      expect(find.text(l10n.detailPlatforms), findsOneWidget);
      expect(find.text('PC, PlayStation 4, Xbox One'), findsOneWidget);
      expect(find.text(l10n.detailGenres), findsOneWidget);
      expect(find.text('Action, RPG'), findsOneWidget);
      expect(find.text(l10n.detailDevelopers), findsOneWidget);
      expect(find.text('CD PROJEKT RED'), findsOneWidget);
    });

    testWidgets('handles entities missing optional data gracefully', (
      WidgetTester tester,
    ) async {
      const emptyMedia = Media(
        id: 2,
        title: 'Unknown Title',
        mediaType: MediaType.movie,
      );

      await tester.pumpWidget(createWidgetUnderTest(emptyMedia));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('Unknown Title'), findsOneWidget);
      expect(
        find.text(l10n.detailSynopsis),
        findsNothing,
      ); // Should not display synopsis section if null
    });
  });
}
