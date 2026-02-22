import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_history_provider.g.dart';

/// Represents a single discovery query and its timestamp.
/// For now, we store just the string query. In the future this could be a more complex object.
class DiscoverHistoryItem {
  final String query;
  final DateTime timestamp;

  DiscoverHistoryItem({required this.query, required this.timestamp});
}

@Riverpod(keepAlive: true)
class DiscoverHistory extends _$DiscoverHistory {
  @override
  List<DiscoverHistoryItem> build() {
    // Initial state: empty history
    return [];
  }

  void addQuery(String query) {
    if (query.trim().isEmpty) return;

    final normalizedQuery = query.trim();
    final filteredHistory = state
        .where((item) => item.query != normalizedQuery)
        .toList();

    final newHistory = [
      DiscoverHistoryItem(query: normalizedQuery, timestamp: DateTime.now()),
      ...filteredHistory,
    ];

    state = newHistory.take(20).toList();
  }

  void clearHistory() {
    state = [];
  }
}
