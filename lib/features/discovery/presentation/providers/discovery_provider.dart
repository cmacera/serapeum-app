import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DiscoverState { initial, result }

class DiscoveryStateData {
  final DiscoverState state;
  final String? currentQuery;

  DiscoveryStateData({this.state = DiscoverState.initial, this.currentQuery});

  DiscoveryStateData copyWith({DiscoverState? state, String? currentQuery}) {
    return DiscoveryStateData(
      state: state ?? this.state,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

class DiscoveryNotifier extends StateNotifier<DiscoveryStateData> {
  DiscoveryNotifier() : super(DiscoveryStateData());

  void startNewConversation() {
    state = DiscoveryStateData(state: DiscoverState.initial);
  }

  void executeSearch(String query) {
    if (query.trim().isEmpty) return;
    state = DiscoveryStateData(
      state: DiscoverState.result,
      currentQuery: query.trim(),
    );
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryStateData>((ref) {
      return DiscoveryNotifier();
    });
