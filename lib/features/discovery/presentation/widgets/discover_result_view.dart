import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

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
              Center(child: Text(l10n.noResponseFromOracle)),
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
              l10n.resultIntro,
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
                  text: l10n.oracleErrorTemplate(
                    error,
                    (details != null && details.isNotEmpty) ? '\n$details' : '',
                  ),
                  isUser: false,
                ),
              ],
            ),
        };
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) {
        debugPrint('Error querying the Oracle: $err\n$stack');
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          children: [
            ChatMessageBubble(text: query, isUser: true),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChatMessageBubble(text: l10n.queryFailed, isUser: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultList(
    BuildContext context,
    String text,
    SearchAllResponse data,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final hasResults =
        data.media.isNotEmpty || data.books.isNotEmpty || data.games.isNotEmpty;

    final allCards = [
      for (final media in data.media)
        MediaResultCard(
          title: media.title ?? media.name ?? l10n.unknownMedia,
          subtitle: media.mediaType.name.toUpperCase(),
          imageUrl: media.posterPath != null
              ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
              : null,
          description: media.overview,
        ),
      for (final book in data.books)
        MediaResultCard(
          title: book.title,
          subtitle: l10n.bookSubtitle(book.publishedDate ?? l10n.unknownYear),
          imageUrl:
              book.imageLinks?['thumbnail'] ??
              book.imageLinks?['smallThumbnail'],
          description: book.description,
        ),
      for (final game in data.games)
        MediaResultCard(
          title: game.name,
          subtitle: l10n.gameSubtitle,
          imageUrl: game.coverUrl,
          description: game.summary,
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.noMatches,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
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
