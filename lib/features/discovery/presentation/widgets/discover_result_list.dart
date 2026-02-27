import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/search_all_response.dart';
import 'category_tab_bar.dart';
import 'chat_message_bubble.dart';
import 'media_result_card.dart';

class DiscoverResultList extends StatefulWidget {
  final String query;
  final String assistantText;
  final SearchAllResponse response;

  const DiscoverResultList({
    super.key,
    required this.query,
    required this.assistantText,
    required this.response,
  });

  @override
  State<DiscoverResultList> createState() => _DiscoverResultListState();
}

class _DiscoverResultListState extends State<DiscoverResultList> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.response;

    final hasMedia = data.media.isNotEmpty;
    final hasBooks = data.books.isNotEmpty;
    final hasGames = data.games.isNotEmpty;

    final hasResults = hasMedia || hasBooks || hasGames;

    // Check how many categories have results
    int categoriesWithResults = 0;
    if (hasMedia) categoriesWithResults++;
    if (hasBooks) categoriesWithResults++;
    if (hasGames) categoriesWithResults++;

    final showTabs = categoriesWithResults >= 2;

    List<Widget> cards = _buildFilteredCards(context, l10n, data);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChatMessageBubble(text: widget.query, isUser: true),
                const SizedBox(height: 16),
                ChatMessageBubble(text: widget.assistantText, isUser: false),
                if (!hasResults)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.noMatches,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                if (showTabs && hasResults) ...[
                  const SizedBox(height: 24),
                  CategoryTabBar(
                    filterAllLabel: l10n.filterAll,
                    filterMediaLabel: l10n.filterMedia,
                    filterBooksLabel: l10n.filterBooks,
                    filterGamesLabel: l10n.filterGames,
                    hasMedia: hasMedia,
                    hasBooks: hasBooks,
                    hasGames: hasGames,
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        if (cards.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: 32.0 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.65,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => cards[index],
                childCount: cards.length,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildFilteredCards(
    BuildContext context,
    AppLocalizations l10n,
    SearchAllResponse data,
  ) {
    List<Widget> cards = [];

    if (_selectedCategory == null || _selectedCategory == 'Media') {
      cards.addAll([
        for (final media in data.media)
          MediaResultCard(
            title: media.title ?? media.name ?? l10n.unknownMedia,
            subtitle: media.mediaType.name.toUpperCase(),
            imageUrl: media.posterPath != null
                ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
                : null,
            description: media.overview,
          ),
      ]);
    }

    if (_selectedCategory == null || _selectedCategory == 'Books') {
      cards.addAll([
        for (final book in data.books)
          MediaResultCard(
            title: book.title,
            subtitle: l10n.bookSubtitle(book.publishedDate ?? l10n.unknownYear),
            imageUrl:
                book.imageLinks?['thumbnail'] ??
                book.imageLinks?['smallThumbnail'],
            description: book.description,
          ),
      ]);
    }

    if (_selectedCategory == null || _selectedCategory == 'Games') {
      cards.addAll([
        for (final game in data.games)
          MediaResultCard(
            title: game.name,
            subtitle: l10n.gameSubtitle,
            imageUrl: game.coverUrl,
            description: game.summary,
          ),
      ]);
    }

    return cards;
  }
}
