import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/core/realm/realm_provider.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';

part 'library_provider.g.dart';

@Riverpod(keepAlive: true)
class Library extends _$Library {
  @override
  List<LibraryItem> build() {
    final realm = ref.read(realmProvider);
    final results = realm.all<LibraryItem>().query(
      'TRUEPREDICATE SORT(addedAt DESC)',
    );

    final sub = results.changes.listen((c) => state = c.results.toList());
    ref.onDispose(sub.cancel);

    return results.toList();
  }

  void addItem({
    required String externalId,
    required String mediaType,
    required String title,
    String? subtitle,
    String? imageUrl,
    String? backdropImageUrl,
    double? rating,
    required String itemJson,
  }) {
    final realm = ref.read(realmProvider);
    try {
      realm.write(
        () => realm.add(
          LibraryItem(
            ObjectId(),
            externalId,
            mediaType,
            title,
            DateTime.now(),
            itemJson,
            subtitle: subtitle,
            imageUrl: imageUrl,
            backdropImageUrl: backdropImageUrl,
            rating: rating,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Library: failed to add item — $e');
    }
  }

  void removeItem(String externalId) {
    final realm = ref.read(realmProvider);
    try {
      final items = realm.all<LibraryItem>().query(r'externalId == $0', [
        externalId,
      ]);
      realm.write(() => realm.deleteMany(items));
    } catch (e) {
      debugPrint('Library: failed to remove item — $e');
    }
  }

  bool isInLibrary(String externalId) {
    return state.any((item) => item.externalId == externalId);
  }
}
