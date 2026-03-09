import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/discover_category.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/search_all_response.dart';
import '../../../library/data/providers/library_provider.dart';
import 'category_tab_bar.dart';
import 'chat_message_bubble.dart';
import 'discover_detail_modal.dart';
import 'media_result_card.dart';

class DiscoverResultList extends ConsumerStatefulWidget {
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
  ConsumerState<DiscoverResultList> createState() => _DiscoverResultListState();
}

class _DiscoverResultListState extends ConsumerState<DiscoverResultList> {
  DiscoverCategory? _selectedCategory;

  @override
  void didUpdateWidget(covariant DiscoverResultList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.response != oldWidget.response) {
      _validateSelectedCategory();
    }
  }

  void _validateSelectedCategory() {
    if (_selectedCategory == null) return;

    final data = widget.response;
    bool isValid = switch (_selectedCategory!) {
      DiscoverCategory.media => data.media.isNotEmpty,
      DiscoverCategory.books => data.books.isNotEmpty,
      DiscoverCategory.games => data.games.isNotEmpty,
    };

    if (!isValid) {
      _selectedCategory = null;
    }
  }

  void _confirmRemove(
    BuildContext context,
    String itemTitle,
    VoidCallback onConfirmed,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<bool>(
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
    ).then((confirmed) {
      if (mounted && confirmed == true) onConfirmed();
    });
  }

  String _persistedMediaType(MediaType type) =>
      type == MediaType.tv ? 'tv' : 'movie';

  void _toggleSaveMedia(BuildContext context, Media media) {
    final externalId = media.id.toString();
    final persistedType = _persistedMediaType(media.mediaType);
    final library = ref.read(libraryProvider.notifier);
    if (library.isInLibrary(externalId, persistedType)) {
      _confirmRemove(context, media.title ?? media.name ?? '', () {
        library.removeItem(externalId, persistedType);
      });
    } else {
      final resolvedImage = media.posterPath != null
          ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
          : null;
      final resolvedBackdrop = media.backdropPath != null
          ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW780}${media.backdropPath}'
          : null;
      library.addItem(
        externalId: externalId,
        mediaType: persistedType,
        title: media.title ?? media.name ?? '',
        subtitle: _buildSubtitle(
          _extractYear(media.releaseDate),
          _formatRating(media.voteAverage),
        ),
        imageUrl: resolvedImage,
        backdropImageUrl: resolvedBackdrop,
        rating: media.voteAverage?.toDouble(),
        itemJson: jsonEncode(media.toJson()),
      );
    }
  }

  void _toggleSaveBook(BuildContext context, Book book) {
    final externalId = book.id;
    const mediaType = 'book';
    final library = ref.read(libraryProvider.notifier);
    if (library.isInLibrary(externalId, mediaType)) {
      _confirmRemove(context, book.title, () {
        library.removeItem(externalId, mediaType);
      });
    } else {
      final imageUrl =
          book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'];
      library.addItem(
        externalId: externalId,
        mediaType: mediaType,
        title: book.title,
        subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
        imageUrl: imageUrl,
        backdropImageUrl: imageUrl,
        rating: book.averageRating?.toDouble(),
        itemJson: jsonEncode(book.toJson()),
      );
    }
  }

  void _toggleSaveGame(BuildContext context, Game game) {
    final externalId = game.id.toString();
    const mediaType = 'game';
    final library = ref.read(libraryProvider.notifier);
    if (library.isInLibrary(externalId, mediaType)) {
      _confirmRemove(context, game.name, () {
        library.removeItem(externalId, mediaType);
      });
    } else {
      library.addItem(
        externalId: externalId,
        mediaType: mediaType,
        title: game.name,
        subtitle: _buildSubtitle(
          _extractYear(game.released),
          _formatRating(game.rating ?? game.aggregatedRating),
        ),
        imageUrl: game.coverUrl,
        backdropImageUrl: game.screenshots?.firstOrNull,
        rating: (game.rating ?? game.aggregatedRating)?.toDouble(),
        itemJson: jsonEncode(game.toJson()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.response;
    final libraryItems = ref.watch(libraryProvider);

    final hasMedia = data.media.isNotEmpty;
    final hasBooks = data.books.isNotEmpty;
    final hasGames = data.games.isNotEmpty;

    final hasResults = hasMedia || hasBooks || hasGames;

    int categoriesWithResults = 0;
    if (hasMedia) categoriesWithResults++;
    if (hasBooks) categoriesWithResults++;
    if (hasGames) categoriesWithResults++;

    final showTabs = categoriesWithResults >= 2;

    List<Widget> cards = _buildFilteredCards(context, l10n, data, libraryItems);

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
            sliver: SliverToBoxAdapter(child: _buildMasonryGrid(cards)),
          ),
      ],
    );
  }

  void _showDetails(BuildContext context, Object entity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        var dismissing = false;
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (!dismissing && notification.extent <= notification.minExtent) {
              dismissing = true;
              Navigator.pop(modalContext);
            }
            return false;
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.9],
            shouldCloseOnMinExtent: true,
            builder: (_, controller) => DiscoverDetailModal(
              entity: entity,
              scrollController: controller,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFilteredCards(
    BuildContext context,
    AppLocalizations l10n,
    SearchAllResponse data,
    List<dynamic> libraryItems,
  ) {
    bool saved(String externalId, String mediaType) => libraryItems.any(
      (i) => i.externalId == externalId && i.mediaType == mediaType,
    );

    List<Widget> cards = [];

    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.media) {
      cards.addAll([
        for (final media in data.media)
          MediaResultCard(
            title: media.title ?? media.name ?? l10n.unknownMedia,
            mediaType: media.mediaType == MediaType.tv
                ? MediaCardType.tv
                : MediaCardType.movie,
            subtitle: _buildSubtitle(
              _extractYear(media.releaseDate),
              _formatRating(media.voteAverage),
            ),
            imageUrl: media.posterPath != null
                ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${media.posterPath}'
                : null,
            onTap: () => _showDetails(context, media),
            isSaved: saved(
              media.id.toString(),
              _persistedMediaType(media.mediaType),
            ),
            onSave: () => _toggleSaveMedia(context, media),
          ),
      ]);
    }

    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.books) {
      cards.addAll([
        for (final book in data.books)
          MediaResultCard(
            title: book.title,
            mediaType: MediaCardType.book,
            subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
            imageUrl:
                book.imageLinks?['thumbnail'] ??
                book.imageLinks?['smallThumbnail'],
            onTap: () => _showDetails(context, book),
            isSaved: saved(book.id, 'book'),
            onSave: () => _toggleSaveBook(context, book),
          ),
      ]);
    }

    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.games) {
      cards.addAll([
        for (final game in data.games)
          MediaResultCard(
            title: game.name,
            mediaType: MediaCardType.game,
            subtitle: _buildSubtitle(
              _extractYear(game.released),
              _formatRating(game.rating ?? game.aggregatedRating),
            ),
            imageUrl: game.coverUrl,
            onTap: () => _showDetails(context, game),
            isSaved: saved(game.id.toString(), 'game'),
            onSave: () => _toggleSaveGame(context, game),
          ),
      ]);
    }

    return cards;
  }

  Widget _buildMasonryGrid(List<Widget> cards) {
    final leftCards = <Widget>[];
    final rightCards = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      if (i.isEven) {
        leftCards.add(cards[i]);
      } else {
        rightCards.add(cards[i]);
      }
    }

    Widget column(List<Widget> items) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: w,
              ),
            )
            .toList(),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        column(leftCards),
        const SizedBox(width: 16),
        column(rightCards),
      ],
    );
  }

  String? _extractYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final match = RegExp(r'\d{4}').firstMatch(dateStr);
    return match?.group(0);
  }

  String? _formatRating(num? rating) {
    if (rating == null || rating == 0) return null;
    return '★ ${rating.toStringAsFixed(1)}';
  }

  String? _buildSubtitle(String? year, String? rating) {
    final parts = [year, rating].whereType<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join('  ·  ');
  }
}
