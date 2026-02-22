import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/search_all_response.dart';
import '../../data/providers/discovery_providers.dart';

part 'discover_query_provider.g.dart';

@riverpod
Future<SearchAllResponse?> discoverQuery(
  DiscoverQueryRef ref,
  String query,
) async {
  if (query.isEmpty) return null;

  final repository = ref.watch(discoveryRepositoryProvider);

  // We specify basic parameters for the overarching query
  return await repository.searchAll(query);
}
