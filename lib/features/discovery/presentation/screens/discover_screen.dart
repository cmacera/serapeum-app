import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'discover_result_screen.dart';
import '../providers/discover_history_provider.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(discoverHistoryProvider);
    final textController = TextEditingController();

    void submitSearch(String query) {
      if (query.trim().isEmpty) return;

      // Save query to history
      ref.read(discoverHistoryProvider.notifier).addQuery(query.trim());
      textController.clear();

      // Navigate to result screen as a modal bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (context) => DiscoverResultScreen(query: query.trim()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(item.query),
                        onTap: () {
                          // Allow re-running a previous query
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            useSafeArea: true,
                            backgroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24.0),
                              ),
                            ),
                            builder: (context) =>
                                DiscoverResultScreen(query: item.query),
                          );
                        },
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF1E1E1E,
                  ).withValues(alpha: 0.8), // Dark highlighted capsule
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: submitSearch,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ask the Oracle anything...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF930DF2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF930DF2,
                            ).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => submitSearch(textController.text),
                        tooltip: 'Ask Oracle',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
