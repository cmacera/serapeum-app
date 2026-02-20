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

      // Navigate to result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiscoverResultScreen(query: query.trim()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SERAPEUM',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'The Oracle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Ask The Oracle to discover new media.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(item.query),
                        onTap: () {
                          // Allow re-running a previous query
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  DiscoverResultScreen(query: item.query),
                            ),
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: textController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: submitSearch,
                  decoration: InputDecoration(
                    hintText: 'Search or ask...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => submitSearch(textController.text),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Use a consistent app-level nav bar later, but scaffolded here based on Stitch design
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Focus on 'explore'
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Widgets'),
        ],
      ),
    );
  }
}
