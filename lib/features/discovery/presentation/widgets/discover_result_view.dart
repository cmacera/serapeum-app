import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/orchestrator_response.dart';
import '../../domain/entities/search_all_response.dart';
import '../providers/discover_query_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/media_result_card.dart';
import '../../../../core/constants/api_constants.dart';

class DiscoverResultView extends ConsumerWidget {
  final String query;

  const DiscoverResultView({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responseAsync = ref.watch(discoverQueryProvider(query));

    return responseAsync.when(
      data: (data) {
        if (data == null) {
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            children: [
              ChatMessageBubble(text: query, isUser: true),
              const SizedBox(height: 16),
              const Center(child: Text('No response from the Oracle.')),
            ],
          );
        }

        return switch (data) {
          OrchestratorMessage(text: final text) => ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ChatMessageBubble(text: query, isUser: true),
              const SizedBox(height: 16),
              ChatMessageBubble(text: text, isUser: false),
            ],
          ),
          OrchestratorGeneral(text: final text, data: final searchData) =>
            _buildResultList(context, text, searchData),
          OrchestratorSelection(
            books: final books,
            media: final media,
            games: final games,
          ) =>
            _buildResultList(
              context,
              'Here is what I found specifically for your request:',
              SearchAllResponse(
                books: books ?? [],
                media: media ?? [],
                games: games ?? [],
              ),
            ),
          OrchestratorError(error: final error, details: final details) =>
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ChatMessageBubble(text: query, isUser: true),
                const SizedBox(height: 16),
                ChatMessageBubble(
                  text:
                      'The Oracle encountered an error: $error'
                      '${(details != null && details.isNotEmpty) ? '\n$details' : ''}',
                  isUser: false,
                ),
              ],
            ),
        };
      },
      loading: () => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        children: [
          ChatMessageBubble(text: query, isUser: true),
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (err, stack) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        children: [
          ChatMessageBubble(text: query, isUser: true),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ChatMessageBubble(
              text: 'Error querying the Oracle: $err',
              isUser: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(
    BuildContext context,
    String text,
    SearchAllResponse data,
  ) {
    final hasResults =
        data.media.isNotEmpty || data.books.isNotEmpty || data.games.isNotEmpty;

    final allCards = [
      for (final media in data.media)
        MediaResultCard(
          title: media.title ?? media.name ?? 'Unknown Media',
          subtitle: media.mediaType.toString().split('.').last.toUpperCase(),
          description: media.overview,
          imageUrl: media.posterPath != null
              ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
              : null,
        ),
      for (final book in data.books)
        MediaResultCard(
          title: book.title,
          subtitle: 'BOOK · ${book.publishedDate ?? 'Unknown Year'}',
          description: book.description,
          imageUrl:
              book.imageLinks?['thumbnail'] ??
              book.imageLinks?['smallThumbnail'],
        ),
      for (final game in data.games)
        MediaResultCard(
          title: game.name,
          subtitle: 'GAME',
          description: game.summary,
          imageUrl: game.coverUrl,
        ),
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChatMessageBubble(text: query, isUser: true),
                const SizedBox(height: 16),
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
              ],
            ),
          ),
        ),
        if (allCards.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: 32.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => allCards[index],
                childCount: allCards.length,
              ),
            ),
          ),
      ],
    );
  }
}
