import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/media_detail_provider.dart';
import 'package:serapeum_app/features/discovery/presentation/widgets/discover_detail_modal.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';
import 'package:serapeum_app/features/library/data/providers/library_provider.dart';
import 'package:serapeum_app/features/library/presentation/widgets/library_user_sections.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

const _testMovieDetail = MovieDetail(
  id: 1,
  title: 'Inception',
  originalTitle: 'Inception',
  tagline: 'Your mind is the scene of the crime.',
  runtime: 148,
  budget: 160000000,
  revenue: 836800000,
  genres: ['Action', 'Science Fiction'],
  cast: [CastMember(id: 1, name: 'Leonardo DiCaprio', character: 'Cobb')],
  watchProviders: {},
);

const _testMovieDetailWithCert = MovieDetail(
  id: 1,
  title: 'Inception',
  originalTitle: 'Inception',
  genres: ['Action', 'Science Fiction'],
  cast: [],
  watchProviders: {},
  certification: 'PG-13',
);

const _testTvDetail = TvDetail(
  id: 2,
  name: 'Breaking Bad',
  originalName: 'Breaking Bad',
  genres: ['Drama', 'Crime'],
  cast: [],
  watchProviders: {},
  seasons: [SeasonSummary(seasonNumber: 1, name: 'Season 1', episodeCount: 7)],
  networks: [Network(id: 174, name: 'AMC')],
  creators: [Creator(id: 1, name: 'Vince Gilligan')],
  episodeRunTime: [47],
);

const _testTvDetailWithCert = TvDetail(
  id: 2,
  name: 'Breaking Bad',
  originalName: 'Breaking Bad',
  genres: ['Drama', 'Crime'],
  cast: [],
  watchProviders: {},
  seasons: [],
  networks: [],
  creators: [],
  episodeRunTime: [],
  certification: 'TV-14',
);

class _FakeLibrary extends Library {
  final List<LibraryItem> _items;
  _FakeLibrary([this._items = const []]);

  @override
  List<LibraryItem> build() => _items;

  @override
  void addItem({
    required String externalId,
    required String mediaType,
    required String title,
    String? subtitle,
    String? imageUrl,
    String? backdropImageUrl,
    double? rating,
    required String itemJson,
  }) {}

  @override
  void removeItem(String externalId, String mediaType) {}

  @override
  void updateUserRating(String externalId, String mediaType, double? rating) {}

  @override
  void updateUserNote(String externalId, String mediaType, String? note) {}
}

LibraryItem _makeLibraryItem({
  required String externalId,
  required String mediaType,
  required String title,
  double? userRating,
  String? userNote,
}) => LibraryItem(
  ObjectId(),
  externalId,
  mediaType,
  title,
  DateTime.now(),
  '{}',
  userRating: userRating,
  userNote: userNote,
);

void main() {
  Widget createWidgetUnderTest(
    Object entity, {
    List<LibraryItem> savedItems = const [],
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        libraryProvider.overrideWith(() => _FakeLibrary(savedItems)),
        ...overrides,
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: DiscoverDetailModal(entity: entity)),
      ),
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

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) async => _testMovieDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('Inception'), findsWidgets);
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
      expect(
        find.textContaining('${l10n.detailIsbn}: 9780451524935'),
        findsOneWidget,
      );
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

      const emptyDetail = MovieDetail(
        id: 2,
        title: 'Unknown Title',
        originalTitle: 'Unknown Title',
        genres: [],
        cast: [],
        watchProviders: {},
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          emptyMedia,
          overrides: [
            movieDetailProvider(2).overrideWith((ref) async => emptyDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text('Unknown Title'), findsOneWidget);
      expect(find.text(l10n.detailSynopsis), findsNothing);
    });

    testWidgets('renders Movie genres from enriched detail', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) async => _testMovieDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.detailGenres), findsOneWidget);
      expect(find.text('Action, Science Fiction'), findsOneWidget);
    });

    testWidgets('shows loading indicator while detail is fetching', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
      );

      final completer = Completer<MovieDetail>();
      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(1).overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.detailLoadingEnriched), findsOneWidget);
    });

    testWidgets('shows error message when detail fetch fails', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) => Future.error(Exception('network error'))),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.detailEnrichmentError), findsOneWidget);
    });

    testWidgets('renders TV enriched sections when loaded', (
      WidgetTester tester,
    ) async {
      const media = Media(id: 2, name: 'Breaking Bad', mediaType: MediaType.tv);

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            tvDetailProvider(2).overrideWith((ref) async => _testTvDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.detailGenres), findsOneWidget);
      expect(find.text('Drama, Crime'), findsOneWidget);
      expect(find.text(l10n.detailCreators), findsOneWidget);
      expect(find.text('Vince Gilligan'), findsOneWidget);
      expect(find.text(l10n.detailNetworks), findsOneWidget);
      expect(find.text('AMC'), findsOneWidget);
      expect(find.text(l10n.detailSeasons), findsOneWidget);
    });

    testWidgets('renders Movie runtime chip when loaded', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) async => _testMovieDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // runtime 148 min = 2h 28m
      expect(find.text('2h 28m'), findsOneWidget);
    });

    testWidgets('renders Book averageRating chip', (WidgetTester tester) async {
      const book = Book(id: '1', title: '1984', averageRating: 4.5);

      await tester.pumpWidget(createWidgetUnderTest(book));
      await tester.pumpAndSettle();

      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('renders Book NOT_MATURE maturity rating chip in header row', (
      WidgetTester tester,
    ) async {
      const book = Book(
        id: '1',
        title: '1984',
        maturityRating: Book.maturityNotMature,
      );

      await tester.pumpWidget(createWidgetUnderTest(book));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.maturityRatingForAll), findsOneWidget);
      expect(find.text(l10n.maturityRatingMature), findsNothing);
      expect(find.text(l10n.detailMaturityRating), findsNothing);
    });

    testWidgets('renders Book MATURE maturity rating chip in header row', (
      WidgetTester tester,
    ) async {
      const book = Book(id: '1', title: '1984', maturityRating: 'MATURE');

      await tester.pumpWidget(createWidgetUnderTest(book));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.maturityRatingMature), findsOneWidget);
      expect(find.text(l10n.maturityRatingForAll), findsNothing);
      expect(find.text(l10n.detailMaturityRating), findsNothing);
    });

    testWidgets('hides Book maturity rating chip when maturityRating is null', (
      WidgetTester tester,
    ) async {
      const book = Book(id: '1', title: '1984');

      await tester.pumpWidget(createWidgetUnderTest(book));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.maturityRatingForAll), findsNothing);
      expect(find.text(l10n.maturityRatingMature), findsNothing);
    });

    testWidgets('renders Game enriched metadata fields', (
      WidgetTester tester,
    ) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(binding.platformDispatcher.clearLocaleTestValue);

      const game = Game(
        id: 1,
        name: 'The Witcher 3',
        themes: ['Fantasy', 'Open World'],
        gameModes: ['Single player'],
        ageRatings: [
          AgeRating(organization: 'ESRB', rating: 'T'),
          AgeRating(organization: 'PEGI', rating: '16'),
        ],
        similarGames: [SimilarGame(id: 2, name: 'Dragon Age: Origins')],
      );

      await tester.pumpWidget(createWidgetUnderTest(game));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(DiscoverDetailModal)),
      )!;

      expect(find.text(l10n.detailThemes), findsOneWidget);
      expect(find.text('Fantasy, Open World'), findsOneWidget);
      expect(find.text(l10n.detailGameModes), findsOneWidget);
      expect(find.text('Single player'), findsOneWidget);
      expect(find.text('ESRB T'), findsOneWidget);
      expect(find.text(l10n.detailSimilarGames), findsOneWidget);
      expect(find.text('Dragon Age: Origins'), findsOneWidget);
    });

    testWidgets(
      'renders Game screenshots section title when screenshots provided',
      (WidgetTester tester) async {
        const game = Game(
          id: 1,
          name: 'Cyberpunk 2077',
          screenshots: ['https://example.com/screenshot1.jpg'],
        );

        await tester.pumpWidget(createWidgetUnderTest(game));
        await tester
            .pump(); // don't settle — network image keeps pending timers

        final l10n = AppLocalizations.of(
          tester.element(find.byType(DiscoverDetailModal)),
        )!;

        expect(find.text(l10n.detailScreenshots), findsOneWidget);
      },
    );

    testWidgets('renders Media originalLanguage chip', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
        originalLanguage: 'en',
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) async => _testMovieDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets(
      'renders Movie certification chip in header row when non-null',
      (WidgetTester tester) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => _testMovieDetailWithCert),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('PG-13'), findsOneWidget);
      },
    );

    testWidgets('hides Movie certification chip when certification is null', (
      WidgetTester tester,
    ) async {
      const media = Media(
        id: 1,
        title: 'Inception',
        mediaType: MediaType.movie,
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            movieDetailProvider(
              1,
            ).overrideWith((ref) async => _testMovieDetail),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PG-13'), findsNothing);
    });

    testWidgets('renders TV certification chip in header row when non-null', (
      WidgetTester tester,
    ) async {
      const media = Media(id: 2, name: 'Breaking Bad', mediaType: MediaType.tv);

      await tester.pumpWidget(
        createWidgetUnderTest(
          media,
          overrides: [
            tvDetailProvider(
              2,
            ).overrideWith((ref) async => _testTvDetailWithCert),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TV-14'), findsOneWidget);
    });

    testWidgets(
      'hides Movie certification chip when certification is empty string',
      (WidgetTester tester) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );
        const detailEmptyCert = MovieDetail(
          id: 1,
          title: 'Inception',
          originalTitle: 'Inception',
          genres: [],
          cast: [],
          watchProviders: {},
          certification: '',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => detailEmptyCert),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('PG-13'), findsNothing);
      },
    );

    testWidgets(
      'hides Movie certification chip when certification is whitespace only',
      (WidgetTester tester) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );
        const detailWhitespaceCert = MovieDetail(
          id: 1,
          title: 'Inception',
          originalTitle: 'Inception',
          genres: [],
          cast: [],
          watchProviders: {},
          certification: '   ',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => detailWhitespaceCert),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('   '), findsNothing);
      },
    );

    testWidgets(
      'hides TV certification chip when certification is empty string',
      (WidgetTester tester) async {
        const media = Media(
          id: 2,
          name: 'Breaking Bad',
          mediaType: MediaType.tv,
        );
        const detailEmptyCert = TvDetail(
          id: 2,
          name: 'Breaking Bad',
          originalName: 'Breaking Bad',
          genres: [],
          cast: [],
          watchProviders: {},
          seasons: [],
          networks: [],
          creators: [],
          episodeRunTime: [],
          certification: '',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              tvDetailProvider(2).overrideWith((ref) async => detailEmptyCert),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('TV-14'), findsNothing);
      },
    );

    testWidgets(
      'hides TV certification chip when certification is whitespace only',
      (WidgetTester tester) async {
        const media = Media(
          id: 2,
          name: 'Breaking Bad',
          mediaType: MediaType.tv,
        );
        const detailWhitespaceCert = TvDetail(
          id: 2,
          name: 'Breaking Bad',
          originalName: 'Breaking Bad',
          genres: [],
          cast: [],
          watchProviders: {},
          seasons: [],
          networks: [],
          creators: [],
          episodeRunTime: [],
          certification: '   ',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              tvDetailProvider(
                2,
              ).overrideWith((ref) async => detailWhitespaceCert),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('   '), findsNothing);
      },
    );

    group('bookmark button', () {
      testWidgets('shows bookmark_border when entity is not saved', (
        WidgetTester tester,
      ) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => _testMovieDetail),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
        expect(find.byIcon(Icons.bookmark), findsNothing);
      });

      testWidgets('shows bookmark when entity is saved', (
        WidgetTester tester,
      ) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );
        final savedItem = _makeLibraryItem(
          externalId: '1',
          mediaType: 'movie',
          title: 'Inception',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            savedItems: [savedItem],
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => _testMovieDetail),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.bookmark), findsOneWidget);
        expect(find.byIcon(Icons.bookmark_border), findsNothing);
      });

      testWidgets('shows user sections when entity is saved', (
        WidgetTester tester,
      ) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );
        final savedItem = _makeLibraryItem(
          externalId: '1',
          mediaType: 'movie',
          title: 'Inception',
          userRating: 8.5,
          userNote: 'Great film',
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            savedItems: [savedItem],
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => _testMovieDetail),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(UserRatingSection), findsOneWidget);
        expect(find.byType(UserReviewSection), findsOneWidget);
      });

      testWidgets('hides user sections when entity is not saved', (
        WidgetTester tester,
      ) async {
        const media = Media(
          id: 1,
          title: 'Inception',
          mediaType: MediaType.movie,
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            media,
            overrides: [
              movieDetailProvider(
                1,
              ).overrideWith((ref) async => _testMovieDetail),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(UserRatingSection), findsNothing);
        expect(find.byType(UserReviewSection), findsNothing);
      });
    });
  });
}
