import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

Future<void> showRemoveFromLibraryDialog(
  BuildContext context,
  String itemTitle,
  VoidCallback onConfirmed,
) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.removeFromLibrary),
      content: Text(itemTitle),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(l10n.removeFromLibrary),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) onConfirmed();
}
