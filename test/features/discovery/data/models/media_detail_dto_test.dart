import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/discovery/data/models/media_detail_dto.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';

void main() {
  group('MovieDetailDto', () {
    const movieJson = {
      'id': 27205,
      'title': 'Inception',
      'original_title': 'Inception',
      'overview': 'A thief who enters dreams...',
      'tagline': 'Your mind is the scene of the crime.',
      'release_date': '2010-07-16',
      'status': 'Released',
      'original_language': 'en',
      'runtime': 148,
      'budget': 160000000,
      'revenue': 836800000,
      'vote_average': 8.3,
      'vote_count': 34000,
      'popularity': 80.5,
      'poster_path': '/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      'backdrop_path': '/s3TBrRGB1iav7gFOCNx3H31MoES.jpg',
      'genres': ['Action', 'Science Fiction', 'Adventure'],
      'cast': [
        {
          'id': 6193,
          'name': 'Leonardo DiCaprio',
          'character': 'Cobb',
          'profile_path': '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg',
        },
        {
          'id': 24045,
          'name': 'Joseph Gordon-Levitt',
          'character': 'Arthur',
          'profile_path': null,
        },
      ],
      'watch_providers': {
        'US': {
          'link': 'https://www.themoviedb.org/movie/27205/watch?locale=US',
          'flatrate': [
            {
              'logo_path': '/9ghgSC0MA082EL6HLCW3GalykFD.jpg',
              'provider_id': 8,
              'provider_name': 'Netflix',
              'display_priority': 0,
            },
          ],
          'rent': [],
          'buy': [],
        },
        'ES': {
          'link': 'https://www.themoviedb.org/movie/27205/watch?locale=ES',
          'flatrate': [],
          'rent': [
            {
              'logo_path': '/peURlLlr8jggOwK53fJ5wdQl05y.jpg',
              'provider_id': 10,
              'provider_name': 'Amazon Video',
              'display_priority': 1,
            },
          ],
          'buy': [],
        },
      },
    };

    test('fromJson parses all fields correctly', () {
      final dto = MovieDetailDto.fromJson(movieJson);

      expect(dto.id, 27205);
      expect(dto.title, 'Inception');
      expect(dto.originalTitle, 'Inception');
      expect(dto.tagline, 'Your mind is the scene of the crime.');
      expect(dto.runtime, 148);
      expect(dto.budget, 160000000);
      expect(dto.revenue, 836800000);
      expect(dto.genres, ['Action', 'Science Fiction', 'Adventure']);
    });

    test('fromJson parses cast correctly', () {
      final dto = MovieDetailDto.fromJson(movieJson);

      expect(dto.cast.length, 2);
      expect(dto.cast[0].name, 'Leonardo DiCaprio');
      expect(dto.cast[0].character, 'Cobb');
      expect(dto.cast[0].profilePath, '/wo2hJpn04vbtmh0B9utCFdsQhxM.jpg');
      expect(dto.cast[1].profilePath, isNull);
    });

    test('fromJson parses watch_providers map correctly', () {
      final dto = MovieDetailDto.fromJson(movieJson);

      expect(dto.watchProviders.containsKey('US'), isTrue);
      expect(dto.watchProviders.containsKey('ES'), isTrue);
      expect(dto.watchProviders['US']!.flatrate!.length, 1);
      expect(dto.watchProviders['US']!.flatrate![0].providerName, 'Netflix');
      expect(dto.watchProviders['ES']!.rent!.length, 1);
      expect(dto.watchProviders['ES']!.rent![0].providerName, 'Amazon Video');
    });

    test('fromJson handles missing watch_providers gracefully', () {
      final jsonWithoutProviders = Map<String, dynamic>.from(movieJson)
        ..remove('watch_providers');

      final dto = MovieDetailDto.fromJson(jsonWithoutProviders);
      expect(dto.watchProviders, isEmpty);
    });

    test('fromJson handles missing optional fields', () {
      final minimalJson = {
        'id': 1,
        'title': 'Test',
        'original_title': 'Test',
        'genres': <String>[],
        'cast': <Map<String, dynamic>>[],
      };

      final dto = MovieDetailDto.fromJson(minimalJson);
      expect(dto.tagline, isNull);
      expect(dto.runtime, isNull);
      expect(dto.budget, isNull);
      expect(dto.revenue, isNull);
      expect(dto.watchProviders, isEmpty);
    });

    test('toDomain converts to MovieDetail entity correctly', () {
      final dto = MovieDetailDto.fromJson(movieJson);
      final entity = dto.toDomain();

      expect(entity, isA<MovieDetail>());
      expect(entity.id, 27205);
      expect(entity.title, 'Inception');
      expect(entity.cast.length, 2);
      expect(entity.cast[0], isA<CastMember>());
      expect(entity.cast[0].name, 'Leonardo DiCaprio');
      expect(entity.watchProviders.containsKey('US'), isTrue);
      expect(entity.watchProviders['US']!.flatrate!.length, 1);
      expect(entity.watchProviders['US']!.flatrate![0], isA<WatchProvider>());
    });
  });

  group('TvDetailDto', () {
    const tvJson = {
      'id': 1396,
      'name': 'Breaking Bad',
      'original_name': 'Breaking Bad',
      'overview': 'A high school chemistry teacher...',
      'tagline': "I am the one who knocks.",
      'first_air_date': '2008-01-20',
      'last_air_date': '2013-09-29',
      'status': 'Ended',
      'original_language': 'en',
      'seasons_count': 5,
      'episodes_count': 62,
      'episode_run_time': [47, 48],
      'vote_average': 9.5,
      'vote_count': 12000,
      'popularity': 400.0,
      'poster_path': '/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
      'backdrop_path': '/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
      'genres': ['Drama', 'Crime'],
      'cast': [
        {
          'id': 17419,
          'name': 'Bryan Cranston',
          'character': 'Walter White',
          'profile_path': '/7Jahy5LZX2Fo8fGJltMreAI49hC.jpg',
        },
      ],
      'watch_providers': {
        'US': {
          'link': 'https://www.themoviedb.org/tv/1396/watch?locale=US',
          'flatrate': [
            {
              'logo_path': '/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg',
              'provider_id': 384,
              'provider_name': 'HBO Max',
              'display_priority': 0,
            },
          ],
        },
      },
      'seasons': [
        {
          'season_number': 1,
          'name': 'Season 1',
          'episode_count': 7,
          'air_date': '2008-01-20',
          'poster_path': '/1BP4xYv9ZG4ZVHkL7ocOziBbSYH.jpg',
        },
        {
          'season_number': 2,
          'name': 'Season 2',
          'episode_count': 13,
          'air_date': '2009-03-08',
          'poster_path': null,
        },
      ],
      'networks': [
        {
          'id': 174,
          'name': 'AMC',
          'logo_path': '/pmvRmATOCaDykE6JrVoeYxlFHw3.png',
        },
      ],
      'creators': [
        {
          'id': 66633,
          'name': 'Vince Gilligan',
          'profile_path': '/wSTvJGz7QbMkQ9atMN0ND5Z37EB.jpg',
        },
      ],
    };

    test('fromJson parses all fields correctly', () {
      final dto = TvDetailDto.fromJson(tvJson);

      expect(dto.id, 1396);
      expect(dto.name, 'Breaking Bad');
      expect(dto.originalName, 'Breaking Bad');
      expect(dto.seasonsCount, 5);
      expect(dto.episodesCount, 62);
      expect(dto.episodeRunTime, [47, 48]);
      expect(dto.genres, ['Drama', 'Crime']);
    });

    test('fromJson parses seasons correctly', () {
      final dto = TvDetailDto.fromJson(tvJson);

      expect(dto.seasons.length, 2);
      expect(dto.seasons[0].seasonNumber, 1);
      expect(dto.seasons[0].name, 'Season 1');
      expect(dto.seasons[0].episodeCount, 7);
      expect(dto.seasons[1].posterPath, isNull);
    });

    test('fromJson parses networks and creators correctly', () {
      final dto = TvDetailDto.fromJson(tvJson);

      expect(dto.networks.length, 1);
      expect(dto.networks[0].name, 'AMC');
      expect(dto.creators.length, 1);
      expect(dto.creators[0].name, 'Vince Gilligan');
    });

    test('fromJson parses watch_providers map correctly', () {
      final dto = TvDetailDto.fromJson(tvJson);

      expect(dto.watchProviders.containsKey('US'), isTrue);
      expect(dto.watchProviders['US']!.flatrate!.length, 1);
      expect(dto.watchProviders['US']!.flatrate![0].providerName, 'HBO Max');
    });

    test('toDomain converts to TvDetail entity correctly', () {
      final dto = TvDetailDto.fromJson(tvJson);
      final entity = dto.toDomain();

      expect(entity, isA<TvDetail>());
      expect(entity.id, 1396);
      expect(entity.name, 'Breaking Bad');
      expect(entity.seasons.length, 2);
      expect(entity.seasons[0], isA<SeasonSummary>());
      expect(entity.networks[0], isA<Network>());
      expect(entity.creators[0], isA<Creator>());
      expect(entity.creators[0].name, 'Vince Gilligan');
    });

    test('fromJson defaults lists to empty when missing', () {
      final minimalJson = {
        'id': 1,
        'name': 'Test Show',
        'original_name': 'Test Show',
      };

      final dto = TvDetailDto.fromJson(minimalJson);
      expect(dto.genres, isEmpty);
      expect(dto.cast, isEmpty);
      expect(dto.seasons, isEmpty);
      expect(dto.networks, isEmpty);
      expect(dto.creators, isEmpty);
      expect(dto.episodeRunTime, isEmpty);
      expect(dto.watchProviders, isEmpty);
    });
  });

  group('WatchProviderRegionDto', () {
    test('toDomain handles null flatrate/rent/buy', () {
      final dto = WatchProviderRegionDto.fromJson({
        'link': 'https://example.com',
      });

      final entity = dto.toDomain();
      expect(entity.link, 'https://example.com');
      expect(entity.flatrate, isNull);
      expect(entity.rent, isNull);
      expect(entity.buy, isNull);
    });
  });
}
