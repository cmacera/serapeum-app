import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:serapeum_app/features/discovery/domain/entities/orchestrator_response.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/discovery_provider.dart';

class DiscoveryUIHelper {
  static void handleSearchResponse({
    required BuildContext context,
    required OrchestratorResponse? response,
    required DiscoveryStateData currentState,
    required VoidCallback onClear,
  }) {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    if (response is OrchestratorMessage) {
      _showDiscoveryDialog(
        context: context,
        title: l10n.outOfScopeTitle,
        message: response.text,
      );
    } else if (response is OrchestratorError) {
      final String errorMessage = switch (response.error) {
        'NETWORK_ERROR' => l10n.networkError,
        'TIMEOUT_ERROR' => l10n.timeoutError,
        'SERVER_ERROR' => l10n.serverError(
          int.tryParse(response.details ?? '') ?? 0,
        ),
        _ => l10n.oracleErrorTemplate(
          response.error,
          (response.details != null && response.details!.isNotEmpty)
              ? '\n${response.details}'
              : '',
        ),
      };

      _showDiscoveryDialog(
        context: context,
        title: l10n.errorTitle,
        message: errorMessage,
      );
    } else if (response == null &&
        currentState.state == DiscoverState.initial) {
      _showDiscoveryDialog(
        context: context,
        title: l10n.errorTitle,
        message: l10n.queryFailed,
      );
    }

    onClear();
  }

  static void _showDiscoveryDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}
