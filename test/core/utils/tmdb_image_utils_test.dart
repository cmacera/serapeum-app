import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/core/utils/tmdb_image_utils.dart';

void main() {
  group('tmdbPosterUrl', () {
    test('returns null when path is null', () {
      expect(tmdbPosterUrl(null), isNull);
    });

    test('builds w500 URL for a valid path', () {
      expect(
        tmdbPosterUrl('/abc123.jpg'),
        'https://image.tmdb.org/t/p/w500/abc123.jpg',
      );
    });
  });

  group('tmdbBackdropUrl', () {
    test('returns null when path is null', () {
      expect(tmdbBackdropUrl(null), isNull);
    });

    test('builds w780 URL for a valid path', () {
      expect(
        tmdbBackdropUrl('/backdrop.jpg'),
        'https://image.tmdb.org/t/p/w780/backdrop.jpg',
      );
    });
  });
}
