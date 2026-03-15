import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/discovery/data/models/search_all_response_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/featured_item.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';

void main() {
  group('SearchAllResponseDto.fromJson — featured field', () {
    const baseJson = <String, dynamic>{
      'media': <dynamic>[],
      'books': <dynamic>[],
      'games': <dynamic>[],
    };

    // Real shape: { "type": "...", "item": { ...fields } }
    const mediaFeaturedJson = <String, dynamic>{
      'type': 'media',
      'item': {'id': 550, 'title': 'Fight Club', 'media_type': 'movie'},
    };

    const bookFeaturedJson = <String, dynamic>{
      'type': 'book',
      'item': {'id': 'bk_001', 'title': 'Dune'},
    };

    const gameFeaturedJson = <String, dynamic>{
      'type': 'game',
      'item': {'id': 1020, 'name': 'Hades'},
    };

    test('parses featured media correctly', () {
      final json = {...baseJson, 'featured': mediaFeaturedJson};
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isA<FeaturedMedia>());
      final f = dto.featured! as FeaturedMedia;
      expect(f.media.id, 550);
      expect(f.media.title, 'Fight Club');
      expect(f.media.mediaType, MediaType.movie);
    });

    test('parses featured book correctly', () {
      final json = {...baseJson, 'featured': bookFeaturedJson};
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isA<FeaturedBook>());
      final f = dto.featured! as FeaturedBook;
      expect(f.book.id, 'bk_001');
      expect(f.book.title, 'Dune');
    });

    test('parses featured game correctly', () {
      final json = {...baseJson, 'featured': gameFeaturedJson};
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isA<FeaturedGame>());
      final f = dto.featured! as FeaturedGame;
      expect(f.game.id, 1020);
      expect(f.game.name, 'Hades');
    });

    test('returns null featured when type is unknown', () {
      final json = {
        ...baseJson,
        'featured': {
          'type': 'podcast',
          'item': {'id': 99},
        },
      };
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });

    test('returns null featured when field is absent', () {
      final dto = SearchAllResponseDto.fromJson(baseJson);

      expect(dto.featured, isNull);
    });

    test('returns null featured when field is null', () {
      final json = {...baseJson, 'featured': null};
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });

    test('returns null featured when field is not a map', () {
      final json = {...baseJson, 'featured': 'not-a-map'};
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });

    test('returns null featured when item key is absent', () {
      // featured has type but no nested item object
      final json = {
        ...baseJson,
        'featured': {'type': 'media'},
      };
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });

    test('returns null featured when item key is not a map', () {
      final json = {
        ...baseJson,
        'featured': {'type': 'media', 'item': 'not-a-map'},
      };
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });

    test('returns null featured when required field inside item is null', () {
      // The AI orchestrator may return an item with id: null.
      // _parseFeatured must not throw and must not affect the rest of the response.
      final json = {
        ...baseJson,
        'featured': {
          'type': 'game',
          'item': {'id': null, 'name': 'Hades'},
        },
      };
      final dto = SearchAllResponseDto.fromJson(json);

      expect(dto.featured, isNull);
    });
  });

  group('SearchAllResponseDto.toDomain — featured propagation', () {
    test('toDomain propagates featured to SearchAllResponse', () {
      final json = <String, dynamic>{
        'media': <dynamic>[],
        'books': <dynamic>[],
        'games': <dynamic>[],
        'featured': {
          'type': 'media',
          'item': {'id': 27205, 'title': 'Inception', 'media_type': 'movie'},
        },
      };

      final domain = SearchAllResponseDto.fromJson(json).toDomain();

      expect(domain.featured, isA<FeaturedMedia>());
      final f = domain.featured! as FeaturedMedia;
      expect(f.media.id, 27205);
      expect(f.media.title, 'Inception');
    });

    test('toDomain yields null featured when absent', () {
      final json = <String, dynamic>{
        'media': <dynamic>[],
        'books': <dynamic>[],
        'games': <dynamic>[],
      };

      final domain = SearchAllResponseDto.fromJson(json).toDomain();

      expect(domain.featured, isNull);
    });
  });
}
