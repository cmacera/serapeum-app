import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/features/discovery/data/local/discover_history_item.dart';

part 'realm_provider.g.dart';

@Riverpod(keepAlive: true)
Realm realm(RealmRef ref) {
  final config = Configuration.local([DiscoverHistoryItem.schema]);
  final instance = Realm(config);
  ref.onDispose(instance.close);
  return instance;
}
