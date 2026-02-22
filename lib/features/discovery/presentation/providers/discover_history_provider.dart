import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_history_provider.g.dart';

/// The maximum number of search history items to keep.
const int kMaxDiscoverHistoryItems = 20;

/// Represents a single discovery query and its timestamp.
class DiscoverHistoryItem extends Equatable {
  final String query;
  final DateTime timestamp;

  const DiscoverHistoryItem({required this.query, required this.timestamp});

  @override
  List<Object?> get props => [query, timestamp];

  @override
  String toString() =>
      'DiscoverHistoryItem(query: $query, timestamp: $timestamp)';
}

@Riverpod(keepAlive: true)
class DiscoverHistory extends _$DiscoverHistory {
  @override
  List<DiscoverHistoryItem> build() {
    // Initial state: empty history
    return [];
  }

  void addQuery(String query, {DateTime? timestamp}) {
    if (query.trim().isEmpty) return;

    final normalizedQuery = query.trim();
    final lowerQuery = normalizedQuery.toLowerCase();

    // Case-insensitive filtering
    final filteredHistory = state
        .where((item) => item.query.toLowerCase() != lowerQuery)
        .toList();

    final newHistory = [
      DiscoverHistoryItem(
        query: normalizedQuery,
        timestamp: timestamp ?? DateTime.now(),
      ),
      ...filteredHistory,
    ];

    state = newHistory.take(kMaxDiscoverHistoryItems).toList();
  }

  void clearHistory() {
    state = [];
  }
}
