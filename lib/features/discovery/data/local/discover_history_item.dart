import 'package:realm/realm.dart';

part 'discover_history_item.realm.dart';

@RealmModel()
class _DiscoverHistoryItem {
  @PrimaryKey()
  late ObjectId id;
  late String query;
  late DateTime timestamp;

  /// Full Oracle response serialized as JSON string.
  late String resultJson;
}
