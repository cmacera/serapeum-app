import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/discover_category.dart';
import '../../domain/entities/featured_item.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/search_all_response.dart';
import '../../../library/data/local/library_item.dart';
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
    final isValid = switch (_selectedCategory!) {
      DiscoverCategory.media => data.media.isNotEmpty,
      DiscoverCategory.books => data.books.isNotEmpty,
      DiscoverCategory.games => data.games.isNotEmpty,
    };

    if (!isValid) _selectedCategory = null;
  }

  void _showRemoveDialog(
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

  String? _tmdbPosterUrl(String? path) => path != null
      ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}$path'
      : null;

  String? _tmdbBackdropUrl(String? path) => path != null
      ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW780}$path'
      : null;

  (String externalId, String mediaType) _entityKey(Object entity) =>
      switch (entity) {
        Media m => (m.id.toString(), _persistedMediaType(m.mediaType)),
        Book b => (b.id, 'book'),
        Game g => (g.id.toString(), 'game'),
        _ => throw ArgumentError('Unknown entity type: $entity'),
      };

  bool _isSavedEntity(List<LibraryItem> items, Object entity) {
    final (externalId, mediaType) = _entityKey(entity);
    return items.any(
      (i) => i.externalId == externalId && i.mediaType == mediaType,
    );
  }

  void _toggleSaveMedia(BuildContext context, Media media) {
    final externalId = media.id.toString();
    final persistedType = _persistedMediaType(media.mediaType);
    final library = ref.read(libraryProvider.notifier);
    if (library.isInLibrary(externalId, persistedType)) {
      final item = ref
          .read(libraryProvider)
          .where(
            (i) => i.externalId == externalId && i.mediaType == persistedType,
          )
          .firstOrNull;
      if (item?.hasUserData ?? false) {
        _showRemoveDialog(
          context,
          item!.title,
          () => library.removeItem(externalId, persistedType),
        );
      } else {
        library.removeItem(externalId, persistedType);
      }
    } else {
      library.addItem(
        externalId: externalId,
        mediaType: persistedType,
        title: media.title ?? media.name ?? '',
        subtitle: _buildSubtitle(
          _extractYear(media.releaseDate),
          _formatRating(media.voteAverage),
        ),
        imageUrl: _tmdbPosterUrl(media.posterPath),
        backdropImageUrl: _tmdbBackdropUrl(media.backdropPath),
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
      final item = ref
          .read(libraryProvider)
          .where((i) => i.externalId == externalId && i.mediaType == mediaType)
          .firstOrNull;
      if (item?.hasUserData ?? false) {
        _showRemoveDialog(
          context,
          item!.title,
          () => library.removeItem(externalId, mediaType),
        );
      } else {
        library.removeItem(externalId, mediaType);
      }
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
      final item = ref
          .read(libraryProvider)
          .where((i) => i.externalId == externalId && i.mediaType == mediaType)
          .firstOrNull;
      if (item?.hasUserData ?? false) {
        _showRemoveDialog(
          context,
          item!.title,
          () => library.removeItem(externalId, mediaType),
        );
      } else {
        library.removeItem(externalId, mediaType);
      }
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
    final showTabs = [hasMedia, hasBooks, hasGames].where((b) => b).length >= 2;

    final cards = _buildFilteredCards(context, l10n, data, libraryItems);

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
                if (data.featured != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildFeaturedCard(
                      context,
                      data.featured!,
                      libraryItems,
                      l10n,
                    ),
                  ),
                ],
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

  MediaResultCard _buildMediaCard(
    BuildContext context,
    Media media,
    List<LibraryItem> libraryItems,
    AppLocalizations l10n,
  ) => MediaResultCard(
    title: media.title ?? media.name ?? l10n.unknownMedia,
    mediaType: media.mediaType == MediaType.tv
        ? MediaCardType.tv
        : MediaCardType.movie,
    subtitle: _buildSubtitle(
      _extractYear(media.releaseDate),
      _formatRating(media.voteAverage),
    ),
    imageUrl: _tmdbPosterUrl(media.posterPath),
    onTap: () => _showDetails(context, media),
    isSaved: _isSavedEntity(libraryItems, media),
    onSave: () => _toggleSaveMedia(context, media),
  );

  MediaResultCard _buildBookCard(
    BuildContext context,
    Book book,
    List<LibraryItem> libraryItems,
  ) => MediaResultCard(
    title: book.title,
    mediaType: MediaCardType.book,
    subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
    imageUrl:
        book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'],
    onTap: () => _showDetails(context, book),
    isSaved: _isSavedEntity(libraryItems, book),
    onSave: () => _toggleSaveBook(context, book),
  );

  MediaResultCard _buildGameCard(
    BuildContext context,
    Game game,
    List<LibraryItem> libraryItems,
  ) => MediaResultCard(
    title: game.name,
    mediaType: MediaCardType.game,
    subtitle: _buildSubtitle(
      _extractYear(game.released),
      _formatRating(game.rating ?? game.aggregatedRating),
    ),
    imageUrl: game.coverUrl,
    onTap: () => _showDetails(context, game),
    isSaved: _isSavedEntity(libraryItems, game),
    onSave: () => _toggleSaveGame(context, game),
  );

  List<Widget> _buildFilteredCards(
    BuildContext context,
    AppLocalizations l10n,
    SearchAllResponse data,
    List<LibraryItem> libraryItems,
  ) => [
    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.media)
      for (final media in data.media)
        _buildMediaCard(context, media, libraryItems, l10n),
    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.books)
      for (final book in data.books)
        _buildBookCard(context, book, libraryItems),
    if (_selectedCategory == null ||
        _selectedCategory == DiscoverCategory.games)
      for (final game in data.games)
        _buildGameCard(context, game, libraryItems),
  ];

  Widget _buildFeaturedCard(
    BuildContext context,
    FeaturedItem featured,
    List<LibraryItem> libraryItems,
    AppLocalizations l10n,
  ) => switch (featured) {
    FeaturedMedia(:final media) => _buildMediaCard(
      context,
      media,
      libraryItems,
      l10n,
    ),
    FeaturedBook(:final book) => _buildBookCard(context, book, libraryItems),
    FeaturedGame(:final game) => _buildGameCard(context, game, libraryItems),
  };

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
