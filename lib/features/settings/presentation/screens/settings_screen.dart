import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../library/data/providers/library_provider.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../data/providers/backup_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom:
            MediaQuery.paddingOf(context).bottom +
            LayoutConstants.navBarClearance,
      ),
      children: const [_BackupSection()],
    );
  }
}

// ---------------------------------------------------------------------------
// Transparent card helper
// ---------------------------------------------------------------------------

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backup section
// ---------------------------------------------------------------------------

class _BackupSection extends ConsumerWidget {
  const _BackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.watch(backupNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.backupSectionTitle;

    return switch (backup) {
      BackupLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      ),
      BackupAnonymous() => _AnonymousCard(title: title),
      BackupAwaitingConfirmation(:final email) => _AwaitingCard(
        email: email,
        title: title,
      ),
      BackupReady(:final email, :final lastBackup) => _ReadyCard(
        email: email,
        lastBackup: lastBackup,
        title: title,
      ),
      BackupOperationInProgress(:final isRestoring) => _InProgressCard(
        isRestoring: isRestoring,
        title: title,
      ),
      BackupError(:final kind) => _ErrorCard(kind: kind, title: title),
    };
  }
}

// ---------------------------------------------------------------------------
// Anonymous state — description + single sign-in button
// ---------------------------------------------------------------------------

class _AnonymousCard extends ConsumerStatefulWidget {
  const _AnonymousCard({required this.title});
  final String title;

  @override
  ConsumerState<_AnonymousCard> createState() => _AnonymousCardState();
}

class _AnonymousCardState extends ConsumerState<_AnonymousCard> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      title: widget.title,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.backupSectionSubtitle,
              style: const TextStyle(color: AppColors.subtitle),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: l10n.backupEmailHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.backupEmailHint;
                }
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return l10n.backupEmailHint;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.backupSignInButton),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(backupNotifierProvider.notifier)
          .signIn(_emailController.text.trim());
    }
  }
}

// ---------------------------------------------------------------------------
// Awaiting magic link confirmation — centered, full width
// ---------------------------------------------------------------------------

class _AwaitingCard extends StatelessWidget {
  const _AwaitingCard({required this.email, required this.title});
  final String email;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.backupAwaitingTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.backupAwaitingSubtitle(email),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ready state — backup info + action buttons
// ---------------------------------------------------------------------------

class _ReadyCard extends ConsumerWidget {
  const _ReadyCard({required this.email, required this.title, this.lastBackup});
  final String email;
  final String title;
  final BackupMetadata? lastBackup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return _GlassCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.backupSignedInAs(email),
                  style: const TextStyle(
                    color: AppColors.subtitle,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, size: 18),
                tooltip: l10n.backupSignOut,
                color: AppColors.subtitle,
                onPressed: () => _confirmSignOut(context, ref, l10n),
              ),
            ],
          ),
          const Divider(height: 24),
          if (lastBackup == null)
            Text(
              l10n.backupNoBackupYet,
              style: const TextStyle(color: AppColors.subtitle),
            )
          else
            Text(
              l10n.backupLastBackup(
                DateFormat.yMMMd().format(lastBackup!.createdAt),
                lastBackup!.itemCount,
              ),
              style: const TextStyle(color: AppColors.subtitle),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                ref.read(backupNotifierProvider.notifier).createBackup(),
            icon: const Icon(Icons.backup_outlined),
            label: Text(l10n.backupCreateButton),
          ),
          if (lastBackup != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmRestore(context, ref, l10n),
              icon: const Icon(Icons.restore_outlined),
              label: Text(l10n.backupRestoreButton),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupSignOutConfirmTitle),
        content: Text(l10n.backupSignOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.backupSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(backupNotifierProvider.notifier).signOut();
    }
  }

  Future<void> _confirmRestore(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final localCount = ref.read(libraryProvider).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupRestoreConfirmTitle),
        content: Text(
          l10n.backupRestoreConfirmMessage(
            localCount,
            DateFormat.yMMMd().format(lastBackup!.createdAt),
            lastBackup!.itemCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.backupRestoreConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(backupNotifierProvider.notifier).restoreBackup();
    }
  }
}

// ---------------------------------------------------------------------------
// In-progress state
// ---------------------------------------------------------------------------

class _InProgressCard extends StatelessWidget {
  const _InProgressCard({required this.isRestoring, required this.title});
  final bool isRestoring;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              isRestoring
                  ? l10n.backupInProgressRestoring
                  : l10n.backupInProgressCreating,
              style: const TextStyle(color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorCard extends ConsumerWidget {
  const _ErrorCard({required this.kind, required this.title});
  final BackupErrorKind kind;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (kind) {
      BackupErrorKind.network => l10n.backupErrorNetwork,
      BackupErrorKind.notAuthenticated => l10n.backupErrorNotAuthenticated,
      BackupErrorKind.incompatibleSchema => l10n.backupErrorIncompatibleSchema,
      BackupErrorKind.generic => l10n.backupErrorGeneric,
    };
    return _GlassCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                l10n.backupErrorTitle,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.subtitle, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () =>
                ref.read(backupNotifierProvider.notifier).dismissError(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
