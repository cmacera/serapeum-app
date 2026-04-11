import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/backup_repository.dart';
import '../../domain/repositories/i_backup_repository.dart';

/// Provides the [IBackupRepository] implementation.
final backupRepositoryProvider = Provider<IBackupRepository>((ref) {
  return BackupRepository(Supabase.instance.client);
});
