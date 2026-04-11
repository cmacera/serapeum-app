import 'package:realm/realm.dart';

import '../entities/backup_metadata.dart';

// ---------------------------------------------------------------------------
// Domain exceptions thrown by IBackupRepository implementations
// ---------------------------------------------------------------------------

/// No authenticated (non-anonymous) user is available.
class BackupNotAuthenticatedException implements Exception {
  const BackupNotAuthenticatedException();

  @override
  String toString() => 'BackupNotAuthenticatedException';
}

/// The backup was created by a newer version of the app and cannot be restored.
class BackupIncompatibleSchemaException implements Exception {
  const BackupIncompatibleSchemaException({
    required this.backupVersion,
    required this.appVersion,
  });

  final int? backupVersion;
  final int appVersion;

  @override
  String toString() =>
      'BackupIncompatibleSchemaException(backup=$backupVersion, app=$appVersion)';
}

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
