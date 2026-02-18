import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/network/dio_provider.dart';
import 'package:serapeum_app/features/discovery/data/repositories/discovery_repository.dart';
import 'package:serapeum_app/features/discovery/domain/repositories/i_discovery_repository.dart';

/// Provides the [IDiscoveryRepository] implementation.
///
/// Override this provider in tests to inject a mock repository:
/// ```dart
/// container = ProviderContainer(overrides: [
///   discoveryRepositoryProvider.overrideWithValue(MockDiscoveryRepository()),
/// ]);
/// ```
final discoveryRepositoryProvider = Provider<IDiscoveryRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DiscoveryRepository(dio);
});
