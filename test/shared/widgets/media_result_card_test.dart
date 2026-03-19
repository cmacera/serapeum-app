import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/core/enums/media_card_type.dart';
import 'package:serapeum_app/shared/widgets/media_result_card.dart';

// MediaResultCard uses AspectRatio so it needs bounded width to lay out.
Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 200, child: child)),
);

void main() {
  group('MediaResultCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
          ),
        ),
      );
      expect(find.text('Inception'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
            subtitle: '2010  ·  ★ 8.8',
          ),
        ),
      );
      expect(find.text('2010  ·  ★ 8.8'), findsOneWidget);
    });

    testWidgets('hides subtitle when not provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget); // only title
    });

    testWidgets('shows no bookmark when isSaved is null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
          ),
        ),
      );
      expect(find.byIcon(Icons.bookmark_add), findsNothing);
      expect(find.byIcon(Icons.bookmark_added), findsNothing);
    });

    testWidgets('shows bookmark_add when isSaved is false', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
            isSaved: false,
          ),
        ),
      );
      expect(find.byIcon(Icons.bookmark_add), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_added), findsNothing);
    });

    testWidgets('shows bookmark_added when isSaved is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
            isSaved: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_add), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('calls onSave when bookmark is tapped', (tester) async {
      var saved = false;
      await tester.pumpWidget(
        _wrap(
          MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
            isSaved: false,
            onSave: () => saved = true,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.bookmark_add));
      expect(saved, isTrue);
    });

    testWidgets('shows movie icon badge for movie type', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(
            title: 'Inception',
            mediaType: MediaCardType.movie,
          ),
        ),
      );
      // Icon appears in both badge and image fallback (no imageUrl provided)
      expect(find.byIcon(Icons.movie), findsAtLeastNWidgets(1));
    });

    testWidgets('shows import_contacts icon badge for book type', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const MediaResultCard(title: '1984', mediaType: MediaCardType.book),
        ),
      );
      expect(find.byIcon(Icons.import_contacts), findsAtLeastNWidgets(1));
    });
  });
}
