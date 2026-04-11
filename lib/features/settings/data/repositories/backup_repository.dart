import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/realm/realm_provider.dart';
import '../../../library/data/local/library_item.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../domain/repositories/i_backup_repository.dart';

/// Supabase Storage implementation of [IBackupRepository].
///
/// Storage layout: backups/{user_id}/library_backup.json
class BackupRepository implements IBackupRepository {
  BackupRepository(this._supabase);

  final SupabaseClient _supabase;

  static const _bucket = 'backups';
  static const _filename = 'library_backup.json';

  String _backupPath(String userId) => '$userId/$_filename';

  String _requireUserId() {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw StateError('No authenticated user');
    return id;
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
      rethrow;
    }
  }

  @override
  Future<void> restoreBackup(Realm realm) async {
    final userId = _requireUserId();
    final bytes = await _supabase.storage
        .from(_bucket)
        .download(_backupPath(userId));
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

    final backupSchema = json['schema_version'] as int?;
    if (backupSchema == null || backupSchema > kRealmSchemaVersion) {
      throw StateError(
        'Incompatible backup schema: backup=$backupSchema, '
        'app=$kRealmSchemaVersion',
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
