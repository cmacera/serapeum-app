import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_history_provider.g.dart';

/// Represents a single discovery query and its result ID.
/// For now, we store just the string query. In the future this could be a more complex object.
class DiscoverHistoryItem {
  final String query;
  final DateTime timestamp;

  DiscoverHistoryItem({required this.query, required this.timestamp});
}

@riverpod
class DiscoverHistory extends _$DiscoverHistory {
  @override
  List<DiscoverHistoryItem> build() {
    // Initial state: empty history
    return [];
  }

  void addQuery(String query) {
    state = [
      DiscoverHistoryItem(query: query, timestamp: DateTime.now()),
      ...state,
    ];
  }

  void clearHistory() {
    state = [];
  }
}
