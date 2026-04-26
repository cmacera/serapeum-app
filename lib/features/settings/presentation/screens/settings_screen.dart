import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../discovery/presentation/providers/discover_history_provider.dart';
import '../../../library/data/providers/library_provider.dart';
import '../../domain/entities/backup_metadata.dart';
import '../../data/providers/backup_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ResponsiveLayout.contentMaxWidth,
        ),
        child: ListView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom:
                MediaQuery.paddingOf(context).bottom +
                (ResponsiveLayout.isWide(context)
                    ? 0
                    : LayoutConstants.navBarClearance),
          ),
          children: const [
            _BackupSection(),
            SizedBox(height: 16),
            _DataSection(),
            SizedBox(height: 16),
            _AppInfoSection(),
          ],
        ),
      ),
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
      BackupOperationInProgress(:final operation) => _InProgressCard(
        operation: operation,
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
  bool _isSubmitting = false;

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
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: l10n.backupEmailHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.backupEmailRequired;
                }
                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return l10n.backupEmailInvalid;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(l10n.backupActivateButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(backupNotifierProvider.notifier)
          .signIn(_emailController.text.trim());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () => _confirmDeleteBackup(context, ref, l10n),
              icon: const Icon(Icons.cloud_off_outlined),
              label: Text(l10n.backupDeleteButton),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteBackup(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupDeleteConfirmTitle),
        content: Text(l10n.backupDeleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.backupDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(backupNotifierProvider.notifier).deleteBackup();
    }
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
  const _InProgressCard({required this.operation, required this.title});
  final BackupOperation operation;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (operation) {
      BackupOperation.creating => l10n.backupInProgressCreating,
      BackupOperation.restoring => l10n.backupInProgressRestoring,
      BackupOperation.deleting => l10n.backupInProgressDeleting,
    };
    return _GlassCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(color: AppColors.subtitle)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data section — clear library / clear history
// ---------------------------------------------------------------------------

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      title: l10n.dataSectionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => _confirmClearLibrary(context, ref, l10n),
            icon: const Icon(Icons.delete_forever_outlined),
            label: Text(l10n.clearLibrary),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => _confirmClearHistory(context, ref, l10n),
            icon: const Icon(Icons.history_toggle_off_outlined),
            label: Text(l10n.clearHistory),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearLibrary(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearLibraryConfirmTitle),
        content: Text(l10n.clearLibraryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clearLibrary),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final success = ref.read(libraryProvider.notifier).clearLibrary();
      if (!success && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.backupErrorGeneric)));
      }
    }
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearHistory),
        content: Text(l10n.clearHistoryConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clearHistory),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref.read(discoverHistoryProvider.notifier).clearHistory();
    }
  }
}

// ---------------------------------------------------------------------------
// App info section
// ---------------------------------------------------------------------------

class _AppInfoSection extends StatefulWidget {
  const _AppInfoSection();

  @override
  State<_AppInfoSection> createState() => _AppInfoSectionState();
}

class _AppInfoSectionState extends State<_AppInfoSection> {
  late final Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _GlassCard(
      title: l10n.appInfoSectionTitle,
      child: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snap) {
          if (snap.hasError) {
            return Text('—', style: const TextStyle(color: AppColors.subtitle));
          }
          if (!snap.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final info = snap.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: l10n.appInfoVersion, value: info.version),
              const SizedBox(height: 4),
              _InfoRow(label: l10n.appInfoBuild, value: info.buildNumber),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.subtitle)),
        Text(value, style: const TextStyle(color: Colors.white70)),
      ],
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
      BackupErrorKind.auth => l10n.backupErrorAuth,
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
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
