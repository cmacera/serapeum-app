import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/discovery/presentation/widgets/fullscreen_image_viewer.dart';

const _urls = [
  'https://example.com/img1.jpg',
  'https://example.com/img2.jpg',
  'https://example.com/img3.jpg',
];

// PageView animation is 300ms.
const _pageDuration = Duration(milliseconds: 400);

class _PopObserver extends NavigatorObserver {
  int popCount = 0;
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      popCount++;
}

Widget _buildViewer({List<String> urls = _urls, int initialIndex = 0}) {
  return MaterialApp(
    home: FullscreenImageViewer(urls: urls, initialIndex: initialIndex),
  );
}

/// Pumps a home screen with a button that pushes [FullscreenImageViewer]
/// onto the navigator — required for dismiss tests.
Widget _buildWithNav({
  List<String> urls = _urls,
  int initialIndex = 0,
  NavigatorObserver? observer,
}) {
  return MaterialApp(
    navigatorObservers: observer != null ? [observer] : [],
    home: Builder(
      builder: (context) => Scaffold(
        body: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  FullscreenImageViewer(urls: urls, initialIndex: initialIndex),
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

/// Opens the viewer via the navigator and returns after the push animation.
Future<void> _openViewer(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pump(); // dispatch tap
  await tester.pump(const Duration(milliseconds: 350)); // push animation
}

/// Pumps enough for the background fade animation (200ms) to complete,
/// which triggers Navigator.pop() via the status listener.
Future<void> _pumpFadeAndPop(WidgetTester tester) async {
  await tester.pump(); // start background fade
  await tester.pump(
    const Duration(milliseconds: 250),
  ); // complete 200ms fade → pop() fires
}

void main() {
  group('FullscreenImageViewer', () {
    testWidgets('renders close button', (tester) async {
      await tester.pumpWidget(_buildViewer());
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows page indicator dots for multiple images', (
      tester,
    ) async {
      await tester.pumpWidget(_buildViewer());
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsNWidgets(_urls.length));
    });

    testWidgets('hides page indicator when only one image', (tester) async {
      await tester.pumpWidget(
        _buildViewer(urls: ['https://example.com/img1.jpg']),
      );
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsNothing);
    });

    testWidgets('close button calls Navigator.pop()', (tester) async {
      final observer = _PopObserver();
      await tester.pumpWidget(_buildWithNav(observer: observer));
      await tester.pump();
      await _openViewer(tester);

      expect(find.byType(FullscreenImageViewer), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await _pumpFadeAndPop(tester);

      expect(observer.popCount, 1);
    });

    testWidgets('Escape key calls Navigator.pop()', (tester) async {
      final observer = _PopObserver();
      await tester.pumpWidget(_buildWithNav(observer: observer));
      await tester.pump();
      await _openViewer(tester);

      expect(find.byType(FullscreenImageViewer), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _pumpFadeAndPop(tester);

      expect(observer.popCount, 1);
    });

    testWidgets('ArrowRight advances the page indicator', (tester) async {
      await tester.pumpWidget(_buildViewer(initialIndex: 0));
      await tester.pump();

      // First dot is active (width 16), second is not (width 6)
      final dotsBefore = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dotsBefore[0].constraints?.maxWidth, 16);
      expect(dotsBefore[1].constraints?.maxWidth, 6);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(_pageDuration);

      final dotsAfter = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dotsAfter[0].constraints?.maxWidth, 6);
      expect(dotsAfter[1].constraints?.maxWidth, 16);
    });

    testWidgets('ArrowLeft moves to previous page', (tester) async {
      await tester.pumpWidget(_buildViewer(initialIndex: 1));
      await tester.pump();

      final dotsBefore = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dotsBefore[1].constraints?.maxWidth, 16);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.pump(_pageDuration);

      final dotsAfter = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dotsAfter[0].constraints?.maxWidth, 16);
      expect(dotsAfter[1].constraints?.maxWidth, 6);
    });

    testWidgets('ArrowRight does nothing on last page', (tester) async {
      await tester.pumpWidget(_buildViewer(initialIndex: _urls.length - 1));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(_pageDuration);

      expect(find.byType(FullscreenImageViewer), findsOneWidget);
      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dots.last.constraints?.maxWidth, 16);
    });

    testWidgets('ArrowLeft does nothing on first page', (tester) async {
      await tester.pumpWidget(_buildViewer(initialIndex: 0));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.pump(_pageDuration);

      expect(find.byType(FullscreenImageViewer), findsOneWidget);
      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dots.first.constraints?.maxWidth, 16);
    });
  });
}
