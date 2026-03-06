import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/core/realm/realm_provider.dart';
import 'package:serapeum_app/features/discovery/data/local/discover_history_item.dart';
import 'package:realm/realm.dart';

part 'discover_history_provider.g.dart';

@Riverpod(keepAlive: true)
class DiscoverHistory extends _$DiscoverHistory {
  @override
  List<DiscoverHistoryItem> build() {
    final realm = ref.read(realmProvider);
    final results = realm.all<DiscoverHistoryItem>().query(
      'TRUEPREDICATE SORT(timestamp DESC)',
    );

    final sub = results.changes.listen((c) => state = c.results.toList());
    ref.onDispose(sub.cancel);

    return results.toList();
  }

  void addQuery(
    String query, {
    required String resultJson,
    DateTime? timestamp,
  }) {
    if (query.trim().isEmpty) return;
    final realm = ref.read(realmProvider);
    realm.write(
      () => realm.add(
        DiscoverHistoryItem(
          ObjectId(),
          query.trim(),
          timestamp ?? DateTime.now(),
          resultJson,
        ),
      ),
    );
  }

  void deleteItem(DiscoverHistoryItem item) {
    final realm = ref.read(realmProvider);
    realm.write(() => realm.delete(item));
  }

  void clearHistory() {
    final realm = ref.read(realmProvider);
    realm.write(() => realm.deleteAll<DiscoverHistoryItem>());
  }
}
