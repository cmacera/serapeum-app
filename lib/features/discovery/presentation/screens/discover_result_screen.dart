import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/orchestrator_response.dart';
import '../../domain/entities/search_all_response.dart';
import '../providers/discover_query_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/media_result_card.dart';
import '../../../../core/constants/api_constants.dart';

class DiscoverResultScreen extends ConsumerWidget {
  final String query;

  const DiscoverResultScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(discoverQueryProvider(query));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Sheet Header (Drag Handle & Close Button)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Balance for centering
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

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

                return switch (data) {
                  OrchestratorMessage(text: final text) => ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [ChatMessageBubble(text: text, isUser: false)],
                  ),
                  OrchestratorGeneral(
                    text: final text,
                    data: final searchData,
                  ) =>
                    _buildResultList(text, searchData),
                  OrchestratorSelection(
                    books: final books,
                    media: final media,
                    games: final games,
                  ) =>
                    _buildResultList(
                      'Here is what I found specifically for your request:',
                      SearchAllResponse(
                        books: books ?? [],
                        media: media ?? [],
                        games: games ?? [],
                      ),
                    ),
                  OrchestratorError(
                    error: final error,
                    details: final details,
                  ) =>
                    ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        ChatMessageBubble(
                          text:
                              'The Oracle encountered an error: $error\n$details',
                          isUser: false,
                        ),
                      ],
                    ),
                };
              },
              loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildResultList(String text, SearchAllResponse data) {
    final hasResults =
        data.media.isNotEmpty || data.books.isNotEmpty || data.games.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      children: [
        ChatMessageBubble(text: text, isUser: false),
        if (!hasResults)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No matching items found in the catalogs.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
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
                  .toUpperCase(),
              description: media.overview,
              imageUrl: media.posterPath != null
                  ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
                  : null,
            ),
          ),
        // Render Books
        for (final book in data.books)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: MediaResultCard(
              title: book.title,
              subtitle: 'BOOK · ${book.publishedDate ?? 'Unknown Year'}',
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
  }
}
