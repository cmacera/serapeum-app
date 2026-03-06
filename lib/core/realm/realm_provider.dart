import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/features/discovery/data/local/discover_history_item.dart';

part 'realm_provider.g.dart';

/// Increment this when any Realm model changes (fields added/removed/renamed).
const int _kSchemaVersion = 1;

@Riverpod(keepAlive: true)
Realm realm(RealmRef ref) {
  final config = Configuration.local(
    [DiscoverHistoryItem.schema],
    schemaVersion: _kSchemaVersion,
    migrationCallback: (migration, oldSchemaVersion) {
      // Add migration steps here when _kSchemaVersion is incremented.
      // Example for a future field addition:
      // if (oldSchemaVersion < 2) { ... }
    },
  );
  final instance = Realm(config);
  ref.onDispose(instance.close);
  return instance;
}
