import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../providers/discover_history_provider.dart';
import '../../../../core/constants/app_colors.dart';

class DiscoveryHistoryScreen extends ConsumerWidget {
  const DiscoveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(discoverHistoryProvider);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF06061A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF16163A), Color(0xFF06061A)],
            ),
          ),
          child: Column(
            children: [
              // Grabber
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.discoveryHistoryTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (history.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: () => _showClearDialog(context, ref, l10n),
                        tooltip: l10n.clearHistory,
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              // List
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noHistory,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];
                          final locale = l10n.localeName;
                          final formattedDate =
                              '${DateFormat.yMd(locale).format(item.timestamp)} • ${DateFormat.Hm(locale).format(item.timestamp)}';

                          return Dismissible(
                            key: ValueKey(item.id.toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) =>
                                _showDeleteDialog(context, ref, l10n),
                            onDismissed: (_) => ref
                                .read(discoverHistoryProvider.notifier)
                                .deleteItem(item),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              color: Colors.red.withValues(alpha: 0.8),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context, item);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.query,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF16163A),
      title: Text(
        l10n.deleteHistoryItem,
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        l10n.deleteHistoryItemConfirmation,
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            l10n.deleteHistoryItem,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );

  void _showClearDialog(BuildContext context, WidgetRef ref, dynamic l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16163A),
        title: Text(
          l10n.clearHistory,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.clearHistoryConfirmation,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref.read(discoverHistoryProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: Text(
              l10n.clearHistory,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
