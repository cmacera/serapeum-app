import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/core/localization/locale_provider.dart';
import 'package:serapeum_app/features/discovery/data/providers/discovery_providers.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';

part 'media_detail_provider.g.dart';

@riverpod
Future<MovieDetail> movieDetail(MovieDetailRef ref, int id) async {
  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);
  final region = PlatformDispatcher.instance.locale.countryCode;
  return repository.getMovieDetail(id, language: language, region: region);
}

@riverpod
Future<TvDetail> tvDetail(TvDetailRef ref, int id) async {
  final repository = ref.watch(catalogSearchRepositoryProvider);
  final language = ref.watch(localeProvider);
  final region = PlatformDispatcher.instance.locale.countryCode;
  return repository.getTvDetail(id, language: language, region: region);
}
