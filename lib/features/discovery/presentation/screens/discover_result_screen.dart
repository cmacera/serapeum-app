import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/discover_query_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/media_result_card.dart';

class DiscoverResultScreen extends ConsumerWidget {
  final String query;

  const DiscoverResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(discoverQueryProvider(query));

    return Scaffold(
      appBar: AppBar(title: const Text('Result'), centerTitle: true),
      body: Column(
        children: [
          // User's Query Bubble
          ChatMessageBubble(text: query, isUser: true),

          const Divider(height: 1),

          // The Oracle's Response
          Expanded(
            child: responseAsync.when(
              data: (data) {
                if (data == null) {
                  return const Center(
                    child: Text('No response from the Oracle.'),
                  );
                }

                final hasResults =
                    data.media.isNotEmpty ||
                    data.books.isNotEmpty ||
                    data.games.isNotEmpty;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 8.0,
                  ),
                  children: [
                    ChatMessageBubble(
                      text: hasResults
                          ? 'Here is what I found:'
                          : 'I could not find anything matching that query.',
                      isUser: false,
                    ),
                    const SizedBox(height: 16),
                    // Render Media
                    for (final media in data.media)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: MediaResultCard(
                          title: media.title ?? media.name ?? 'Unknown Media',
                          subtitle: media.mediaType
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(), // basic formatting
                          description: media.overview,
                          imageUrl: media.posterPath != null
                              ? 'https://image.tmdb.org/t/p/w500${media.posterPath}'
                              : null,
                        ),
                      ),
                    // Render Books
                    for (final book in data.books)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: MediaResultCard(
                          title: book.title,
                          subtitle:
                              'BOOK · ${book.publishedDate ?? 'Unknown Year'}',
                          description: book.description,
                          imageUrl:
                              book.imageLinks?['thumbnail'] ??
                              book.imageLinks?['smallThumbnail'],
                        ),
                      ),
                    // Render Games
                    for (final game in data.games)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: MediaResultCard(
                          title: game.name,
                          subtitle: 'GAME',
                          description: game.summary,
                          imageUrl: game.coverUrl,
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: ChatMessageBubble(
                  text: 'Error querying the Oracle: $err',
                  isUser: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
