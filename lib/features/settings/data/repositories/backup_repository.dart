import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/realm/realm_schema_version.dart';
import '../../../library/data/local/library_item.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../domain/repositories/i_backup_repository.dart';

/// Supabase Storage implementation of [IBackupRepository].
///
/// Storage layout: backups/{user_id}/library_backup.json
///
/// All public methods surface only typed domain exceptions
/// ([BackupNotAuthenticatedException], [BackupIncompatibleSchemaException])
/// or [Failure] subclasses ([NetworkFailure], [ServerFailure]) so callers
/// never need to inspect raw exception messages.
class BackupRepository implements IBackupRepository {
  BackupRepository(this._supabase);

  final SupabaseClient _supabase;

  static const _bucket = 'backups';
  static const _filename = 'library_backup.json';

  String _backupPath(String userId) => '$userId/$_filename';

  String _requireUserId() {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw const BackupNotAuthenticatedException();
    return id;
  }

  /// Maps a [StorageException] to a [Failure] subclass.
  /// 404 / "not found" → null (caller handles)
  /// Network-level → [NetworkFailure]
  /// Server error → [ServerFailure]
  Never _mapStorageException(StorageException e) {
    final code = int.tryParse(e.statusCode ?? '');
    if (code != null && code >= 500) {
      throw ServerFailure(statusCode: code, message: e.message);
    }
    if (e.error is SocketException ||
        e.message.contains('Failed host lookup') ||
        e.message.contains('Connection refused') ||
        e.message.contains('NetworkException')) {
      throw const NetworkFailure();
    }
    throw ServerFailure(statusCode: code ?? 0, message: e.message);
  }

  @override
  Future<void> createBackup(Realm realm) async {
    final userId = _requireUserId();
    final items = realm.all<LibraryItem>().toList();
    final payload = {
      'schema_version': kRealmSchemaVersion,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'item_count': items.length,
      'items': items.map(_itemToJson).toList(),
    };
    final bytes = utf8.encode(jsonEncode(payload));
    try {
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(
            _backupPath(userId),
            bytes,
            fileOptions: const FileOptions(
              contentType: 'application/json',
              upsert: true,
            ),
          );
    } on StorageException catch (e) {
      _mapStorageException(e);
    }
    debugPrint('BackupRepository: backup created (${items.length} items)');
  }

  @override
  Future<BackupMetadata?> getBackupMetadata() async {
    final userId = _requireUserId();
    try {
      final bytes = await _supabase.storage
          .from(_bucket)
          .download(_backupPath(userId));
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      return BackupMetadata.fromJson(json);
    } on StorageException catch (e) {
      if (e.statusCode == '404' || e.message.contains('not found')) {
        return null;
      }
      _mapStorageException(e);
    }
  }

  @override
  Future<void> restoreBackup(Realm realm) async {
    final userId = _requireUserId();
    final Uint8List bytes;
    try {
      bytes = await _supabase.storage
          .from(_bucket)
          .download(_backupPath(userId));
    } on StorageException catch (e) {
      _mapStorageException(e);
    }
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    final backupSchema = json['schema_version'] as int?;
    if (backupSchema == null || backupSchema > kRealmSchemaVersion) {
      throw BackupIncompatibleSchemaException(
        backupVersion: backupSchema,
        appVersion: kRealmSchemaVersion,
      );
    }

    final rawItems = json['items'] as List<dynamic>;
    final items = rawItems
        .map((e) => _itemFromJson(e as Map<String, dynamic>))
        .toList();

    if (rawItems.isNotEmpty && items.isEmpty) {
      throw StateError('Failed to parse backup items');
    }

    realm.write(() {
      realm.deleteAll<LibraryItem>();
      realm.addAll(items);
    });
    debugPrint('BackupRepository: restored ${items.length} items');
  }

  Map<String, dynamic> _itemToJson(LibraryItem item) => {
    'id': item.id.hexString,
    'externalId': item.externalId,
    'mediaType': item.mediaType,
    'title': item.title,
    'subtitle': item.subtitle,
    'imageUrl': item.imageUrl,
    'backdropImageUrl': item.backdropImageUrl,
    'rating': item.rating,
    'addedAt': item.addedAt.toUtc().toIso8601String(),
    'itemJson': item.itemJson,
    'userRating': item.userRating,
    'userNote': item.userNote,
    'isConsumed': item.isConsumed,
  };

  LibraryItem _itemFromJson(Map<String, dynamic> json) => LibraryItem(
    ObjectId.fromHexString(json['id'] as String),
    json['externalId'] as String,
    json['mediaType'] as String,
    json['title'] as String,
    DateTime.parse(json['addedAt'] as String),
    json['itemJson'] as String,
    subtitle: json['subtitle'] as String?,
    imageUrl: json['imageUrl'] as String?,
    backdropImageUrl: json['backdropImageUrl'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    userRating: (json['userRating'] as num?)?.toDouble(),
    userNote: json['userNote'] as String?,
    isConsumed: json['isConsumed'] as bool? ?? false,
  );
}
