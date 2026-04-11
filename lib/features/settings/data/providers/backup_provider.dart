import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/realm/realm_provider.dart';
import '../../../library/data/providers/library_provider.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../domain/repositories/i_backup_repository.dart';
import 'backup_repository_provider.dart';

part 'backup_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class BackupState {}

class BackupLoading extends BackupState {}

class BackupAnonymous extends BackupState {}

class BackupAwaitingConfirmation extends BackupState {
  BackupAwaitingConfirmation(this.email);
  final String email;
}

class BackupReady extends BackupState {
  BackupReady({required this.email, this.lastBackup});
  final String email;
  final BackupMetadata? lastBackup;
}

class BackupOperationInProgress extends BackupState {
  BackupOperationInProgress({
    required this.email,
    this.lastBackup,
    required this.isRestoring,
  });
  final String email;
  final BackupMetadata? lastBackup;
  final bool isRestoring;
}

enum BackupErrorKind { network, notAuthenticated, incompatibleSchema, generic }

class BackupError extends BackupState {
  BackupError({required this.kind, required this.previous});
  final BackupErrorKind kind;
  final BackupState previous;
}

BackupErrorKind _classifyError(Object error) {
  if (error is NetworkFailure || error is TimeoutFailure) {
    return BackupErrorKind.network;
  }
  if (error is BackupNotAuthenticatedException) {
    return BackupErrorKind.notAuthenticated;
  }
  if (error is BackupIncompatibleSchemaException) {
    return BackupErrorKind.incompatibleSchema;
  }
  return BackupErrorKind.generic;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  BackupState build() {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Listen for magic-link confirmation or sign-in events.
    final sub = supabase.auth.onAuthStateChange.listen(_onAuthStateChange);
    ref.onDispose(sub.cancel);

    if (user == null || user.isAnonymous) {
      return BackupAnonymous();
    }

    final email = user.email;
    if (email == null) return BackupAnonymous();

    // Authenticated — load metadata asynchronously and transition to Ready.
    _loadMetadataAndSetReady(email);
    return BackupLoading();
  }

  Future<void> _loadMetadataAndSetReady(String email) async {
    try {
      final metadata = await _repo.getBackupMetadata();
      // Guard: user may have signed out while awaiting — don't overwrite state.
      if (state is BackupAnonymous) return;
      state = BackupReady(email: email, lastBackup: metadata);
    } catch (e) {
      if (state is BackupAnonymous) return;
      debugPrint('BackupNotifier: failed to load metadata — $e');
      state = BackupReady(email: email);
    }
  }

  void _onAuthStateChange(AuthState authState) {
    final event = authState.event;
    final user = authState.session?.user;

    if (user == null || user.isAnonymous) return;

    final email = user.email;
    if (email == null) return;

    if (event == AuthChangeEvent.userUpdated ||
        event == AuthChangeEvent.signedIn) {
      _loadMetadataAndSetReady(email);
    }
  }

  /// Sends a magic link to [email]. Works for both first-time activation
  /// (new account) and sign-in on a second device (existing account).
  Future<void> signIn(String email) async {
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.serapeum://login-callback/',
      );
      state = BackupAwaitingConfirmation(email);
    } catch (e) {
      state = BackupError(kind: _classifyError(e), previous: BackupAnonymous());
    }
  }

  /// Creates a backup from the current Realm state and uploads to Supabase Storage.
  Future<void> createBackup() async {
    final current = state;
    if (current is! BackupReady) return;

    state = BackupOperationInProgress(
      email: current.email,
      lastBackup: current.lastBackup,
      isRestoring: false,
    );

    try {
      final realm = ref.read(realmProvider);
      await _repo.createBackup(realm);
      final metadata = await _repo.getBackupMetadata();
      if (state is BackupAnonymous) return;
      state = BackupReady(email: current.email, lastBackup: metadata);
    } catch (e) {
      if (state is BackupAnonymous) return;
      state = BackupError(kind: _classifyError(e), previous: current);
    }
  }

  /// Downloads the latest backup and replaces the local Realm library.
  Future<void> restoreBackup() async {
    final current = state;
    if (current is! BackupReady) return;

    state = BackupOperationInProgress(
      email: current.email,
      lastBackup: current.lastBackup,
      isRestoring: true,
    );

    try {
      final realm = ref.read(realmProvider);
      await _repo.restoreBackup(realm);
      // Invalidate so Library screen reflects restored items immediately.
      ref.invalidate(libraryProvider);
      final metadata = await _repo.getBackupMetadata();
      if (state is BackupAnonymous) return;
      state = BackupReady(email: current.email, lastBackup: metadata);
    } catch (e) {
      if (state is BackupAnonymous) return;
      state = BackupError(kind: _classifyError(e), previous: current);
    }
  }

  /// Signs out of the backup account and restores an anonymous session
  /// so the app continues to work normally.
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      await Supabase.instance.client.auth.signInAnonymously();
      state = BackupAnonymous();
    } catch (e) {
      state = BackupError(kind: _classifyError(e), previous: state);
    }
  }

  /// Dismisses an error and returns to the previous state.
  void dismissError() {
    final current = state;
    if (current is BackupError) state = current.previous;
  }

  IBackupRepository get _repo => ref.read(backupRepositoryProvider);
}
