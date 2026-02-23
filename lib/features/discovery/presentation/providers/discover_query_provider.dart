import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/orchestrator_response.dart';
import '../../data/providers/discovery_providers.dart';

import '../../../../core/localization/locale_provider.dart';

part 'discover_query_provider.g.dart';

@riverpod
Future<OrchestratorResponse?> discoverQuery(
  DiscoverQueryRef ref,
  String query,
) async {
  if (query.isEmpty) return null;

  final repository = ref.watch(catalogDiscoverRepositoryProvider);
  final language = ref.watch(localeProvider);

  // Propagate device language to ensure content is returned in user's language
  return await repository.orchestrate(query, language: language);
}
