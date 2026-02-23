import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/network/dio_provider.dart';
import 'package:serapeum_app/features/discovery/data/repositories/catalog_discover_repository.dart';
import 'package:serapeum_app/features/discovery/data/repositories/catalog_search_repository.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_discover_repository.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_catalog_search_repository.dart';

/// Provides the [ICatalogSearchRepository] implementation.
final catalogSearchRepositoryProvider = Provider<ICatalogSearchRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return CatalogSearchRepository(dio);
});

/// Provides the [ICatalogDiscoverRepository] implementation.
final catalogDiscoverRepositoryProvider = Provider<ICatalogDiscoverRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);
  return CatalogDiscoverRepository(dio);
});
