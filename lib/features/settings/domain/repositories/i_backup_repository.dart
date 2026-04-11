import 'package:realm/realm.dart';

import '../entities/backup_metadata.dart';

/// Contract for cloud backup/restore operations.
abstract interface class IBackupRepository {
  /// Serialises the current Realm library and uploads it to cloud storage.
  Future<void> createBackup(Realm realm);

  /// Returns metadata (date, item count) of the stored backup,
  /// or null if no backup exists for the current user.
  Future<BackupMetadata?> getBackupMetadata();

  /// Downloads the stored backup and replaces the local Realm library.
  Future<void> restoreBackup(Realm realm);
}
