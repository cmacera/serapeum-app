import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'discover_history_provider.g.dart';

/// The maximum number of search history items to keep.
const int kMaxDiscoverHistoryItems = 20;

/// Key used for persisting search history in SharedPreferences.
const String _kHistoryPrefsKey = 'discover_history';

/// Represents a single discovery query and its timestamp.
class DiscoverHistoryItem extends Equatable {
  final String query;
  final DateTime timestamp;

  const DiscoverHistoryItem({required this.query, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'query': query,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DiscoverHistoryItem.fromJson(Map<String, dynamic> json) =>
      DiscoverHistoryItem(
        query: json['query'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

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
    // Start async loading but return empty list immediately to match Notifier signature
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_kHistoryPrefsKey);

      if (historyJson != null) {
        final loadedHistory = historyJson
            .map((item) => DiscoverHistoryItem.fromJson(jsonDecode(item)))
            .toList();
        state = loadedHistory;
      }
    } catch (_) {
      // Fallback to empty if load fails
      state = [];
    }
  }

  Future<void> addQuery(String query, {DateTime? timestamp}) async {
    if (query.trim().isEmpty) return;

    final normalizedQuery = query.trim();
    final lowerQuery = normalizedQuery.toLowerCase();

    // Deduplicate and limit
    final filteredHistory = state
        .where((item) => item.query.toLowerCase() != lowerQuery)
        .toList();

    final newHistory = [
      DiscoverHistoryItem(
        query: normalizedQuery,
        timestamp: timestamp ?? DateTime.now(),
      ),
      ...filteredHistory,
    ].take(kMaxDiscoverHistoryItems).toList();

    state = newHistory;
    await _persist(newHistory);
  }

  Future<void> clearHistory() async {
    state = [];
    await _persist([]);
  }

  Future<void> _persist(List<DiscoverHistoryItem> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = history
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await prefs.setStringList(_kHistoryPrefsKey, historyJson);
    } catch (_) {
      // Ignore persistence errors for now
    }
  }
}
