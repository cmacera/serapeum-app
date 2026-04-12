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
    if (isInLibrary(externalId, mediaType)) return;
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

  RealmResults<LibraryItem> _queryItems(
    Realm realm,
    String externalId,
    String mediaType,
  ) => realm.all<LibraryItem>().query(r'externalId == $0 AND mediaType == $1', [
    externalId,
    mediaType,
  ]);

  void removeItem(String externalId, String mediaType) {
    final realm = ref.read(realmProvider);
    try {
      final items = _queryItems(realm, externalId, mediaType);
      realm.write(() => realm.deleteMany(items));
    } catch (e) {
      debugPrint('Library: failed to remove item — $e');
    }
  }

  void updateUserRating(String externalId, String mediaType, double? rating) {
    final realm = ref.read(realmProvider);
    try {
      final items = _queryItems(realm, externalId, mediaType);
      realm.write(() {
        for (final item in items) {
          item.userRating = rating;
          if (rating != null && !item.isConsumed) item.isConsumed = true;
        }
      });
    } catch (e) {
      debugPrint('Library: failed to update rating — $e');
    }
  }

  void updateIsConsumed(String externalId, String mediaType, bool value) {
    final realm = ref.read(realmProvider);
    try {
      final items = _queryItems(realm, externalId, mediaType);
      realm.write(() {
        for (final item in items) {
          item.isConsumed = value;
        }
      });
    } catch (e) {
      debugPrint('Library: failed to update consumed status — $e');
    }
  }

  void updateUserNote(String externalId, String mediaType, String? note) {
    final realm = ref.read(realmProvider);
    try {
      final trimmed = note?.trim();
      final items = _queryItems(realm, externalId, mediaType);
      realm.write(() {
        for (final item in items) {
          item.userNote = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
        }
      });
    } catch (e) {
      debugPrint('Library: failed to update note — $e');
    }
  }

  void clearLibrary() {
    final realm = ref.read(realmProvider);
    try {
      realm.write(() => realm.deleteAll<LibraryItem>());
    } catch (e) {
      debugPrint('Library: failed to clear library — $e');
    }
  }

  bool isInLibrary(String externalId, String mediaType) {
    return state.any(
      (item) => item.externalId == externalId && item.mediaType == mediaType,
    );
  }
}
