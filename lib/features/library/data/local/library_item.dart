// dart format width=80
// Handwritten Realm model — realm_generator 3.5.0 cannot resolve @RealmModel()
// with analyzer 7.6.0 + SDK 3.11.0. Written following the exact pattern
// produced by the generator for DiscoverHistoryItem.

// ignore_for_file: type=lint

import 'package:realm/realm.dart';

class LibraryItem with RealmEntity, RealmObjectBase, RealmObject {
  LibraryItem(
    ObjectId id,
    String externalId,
    String mediaType,
    String title,
    DateTime addedAt,
    String itemJson, {
    String? subtitle,
    String? imageUrl,
    String? backdropImageUrl,
    double? rating,
    double? userRating,
    String? userNote,
    bool isConsumed = false,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'externalId', externalId);
    RealmObjectBase.set(this, 'mediaType', mediaType);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'addedAt', addedAt);
    RealmObjectBase.set(this, 'itemJson', itemJson);
    RealmObjectBase.set(this, 'subtitle', subtitle);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'backdropImageUrl', backdropImageUrl);
    RealmObjectBase.set(this, 'rating', rating);
    RealmObjectBase.set(this, 'userRating', userRating);
    RealmObjectBase.set(this, 'userNote', userNote);
    RealmObjectBase.set(this, 'isConsumed', isConsumed);
  }

  LibraryItem._();

  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  String get externalId =>
      RealmObjectBase.get<String>(this, 'externalId') as String;
  set externalId(String value) =>
      RealmObjectBase.set(this, 'externalId', value);

  String get mediaType =>
      RealmObjectBase.get<String>(this, 'mediaType') as String;
  set mediaType(String value) => RealmObjectBase.set(this, 'mediaType', value);

  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  String? get subtitle =>
      RealmObjectBase.get<String>(this, 'subtitle') as String?;
  set subtitle(String? value) => RealmObjectBase.set(this, 'subtitle', value);

  String? get imageUrl =>
      RealmObjectBase.get<String>(this, 'imageUrl') as String?;
  set imageUrl(String? value) => RealmObjectBase.set(this, 'imageUrl', value);

  String? get backdropImageUrl =>
      RealmObjectBase.get<String>(this, 'backdropImageUrl') as String?;
  set backdropImageUrl(String? value) =>
      RealmObjectBase.set(this, 'backdropImageUrl', value);

  double? get rating => RealmObjectBase.get<double>(this, 'rating') as double?;
  set rating(double? value) => RealmObjectBase.set(this, 'rating', value);

  DateTime get addedAt =>
      RealmObjectBase.get<DateTime>(this, 'addedAt') as DateTime;
  set addedAt(DateTime value) => RealmObjectBase.set(this, 'addedAt', value);

  String get itemJson =>
      RealmObjectBase.get<String>(this, 'itemJson') as String;
  set itemJson(String value) => RealmObjectBase.set(this, 'itemJson', value);

  double? get userRating =>
      RealmObjectBase.get<double>(this, 'userRating') as double?;
  set userRating(double? value) =>
      RealmObjectBase.set(this, 'userRating', value);

  String? get userNote =>
      RealmObjectBase.get<String>(this, 'userNote') as String?;
  set userNote(String? value) => RealmObjectBase.set(this, 'userNote', value);

  bool get isConsumed => RealmObjectBase.get<bool>(this, 'isConsumed') as bool;
  set isConsumed(bool value) => RealmObjectBase.set(this, 'isConsumed', value);

  bool get hasUserData =>
      isConsumed ||
      userRating != null ||
      (userNote?.trim().isNotEmpty ?? false);

  @override
  Stream<RealmObjectChanges<LibraryItem>> get changes =>
      RealmObjectBase.getChanges<LibraryItem>(this);

  @override
  Stream<RealmObjectChanges<LibraryItem>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<LibraryItem>(this, keyPaths);

  @override
  LibraryItem freeze() => RealmObjectBase.freezeObject<LibraryItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'externalId': externalId.toEJson(),
      'mediaType': mediaType.toEJson(),
      'title': title.toEJson(),
      'subtitle': subtitle.toEJson(),
      'imageUrl': imageUrl.toEJson(),
      'backdropImageUrl': backdropImageUrl.toEJson(),
      'rating': rating.toEJson(),
      'addedAt': addedAt.toEJson(),
      'itemJson': itemJson.toEJson(),
      'userRating': userRating.toEJson(),
      'userNote': userNote.toEJson(),
      'isConsumed': isConsumed.toEJson(),
    };
  }

  static EJsonValue _toEJson(LibraryItem value) => value.toEJson();
  static LibraryItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'externalId': EJsonValue externalId,
        'mediaType': EJsonValue mediaType,
        'title': EJsonValue title,
        'addedAt': EJsonValue addedAt,
        'itemJson': EJsonValue itemJson,
      } =>
        LibraryItem(
          fromEJson(id),
          fromEJson(externalId),
          fromEJson(mediaType),
          fromEJson(title),
          fromEJson(addedAt),
          fromEJson(itemJson),
          subtitle: fromEJson(ejson['subtitle']),
          imageUrl: fromEJson(ejson['imageUrl']),
          backdropImageUrl: fromEJson(ejson['backdropImageUrl']),
          rating: fromEJson(ejson['rating']),
          userRating: fromEJson(ejson['userRating']),
          userNote: fromEJson(ejson['userNote']),
          isConsumed: fromEJson(ejson['isConsumed'] ?? false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(LibraryItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      LibraryItem,
      'LibraryItem',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty(
          'externalId',
          RealmPropertyType.string,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty(
          'mediaType',
          RealmPropertyType.string,
          indexType: RealmIndexType.regular,
        ),
        SchemaProperty('title', RealmPropertyType.string),
        SchemaProperty('subtitle', RealmPropertyType.string, optional: true),
        SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'backdropImageUrl',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty('rating', RealmPropertyType.double, optional: true),
        SchemaProperty('addedAt', RealmPropertyType.timestamp),
        SchemaProperty('itemJson', RealmPropertyType.string),
        SchemaProperty('userRating', RealmPropertyType.double, optional: true),
        SchemaProperty('userNote', RealmPropertyType.string, optional: true),
        SchemaProperty('isConsumed', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
