import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/features/discovery/data/local/discover_history_item.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';

part 'realm_provider.g.dart';

/// Increment this when any Realm model changes (fields added/removed/renamed).
const int _kSchemaVersion = 3;

@Riverpod(keepAlive: true)
Realm realm(RealmRef ref) {
  final config = Configuration.local(
    [DiscoverHistoryItem.schema, LibraryItem.schema],
    schemaVersion: _kSchemaVersion,
    migrationCallback: (migration, oldSchemaVersion) {
      if (oldSchemaVersion < 2) {
        // LibraryItem added in schema version 2.
      }
      if (oldSchemaVersion < 3) {
        // externalId and mediaType indexed in schema version 3.
        // No data migration required — Realm rebuilds indexes automatically.
      }
    },
  );
  final instance = Realm(config);
  ref.onDispose(instance.close);
  return instance;
}
