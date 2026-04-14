import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/constants/app_colors.dart';
import 'package:serapeum_app/core/enums/discover_category.dart';
import 'package:serapeum_app/core/enums/media_card_type.dart';
import 'package:serapeum_app/core/utils/tmdb_image_utils.dart';
import 'package:serapeum_app/features/discovery/domain/entities/book.dart';
import 'package:serapeum_app/features/discovery/domain/entities/game.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/catalog_search_providers.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';
import 'package:serapeum_app/features/library/data/providers/library_provider.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:serapeum_app/shared/widgets/category_tab_bar.dart';
import 'package:serapeum_app/shared/widgets/media_detail_modal.dart';
import 'package:serapeum_app/shared/widgets/media_result_card.dart';

class AddToLibrarySheet extends ConsumerStatefulWidget {
  const AddToLibrarySheet({super.key});

  @override
  ConsumerState<AddToLibrarySheet> createState() => _AddToLibrarySheetState();
}

class _AddToLibrarySheetState extends ConsumerState<AddToLibrarySheet> {
  DiscoverCategory _selectedCategory = DiscoverCategory.media;
  String _query = '';
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _textController.clear();
    setState(() => _query = '');
  }

  String _persistedMediaType(MediaType type) =>
      type == MediaType.tv ? 'tv' : 'movie';

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

  void _saveMedia(Media media) {
    ref
        .read(libraryProvider.notifier)
        .addItem(
          externalId: media.id.toString(),
          mediaType: _persistedMediaType(media.mediaType),
          title: media.title ?? media.name ?? '',
          subtitle: _buildSubtitle(
            _extractYear(media.releaseDate),
            _formatRating(media.voteAverage),
          ),
          imageUrl: tmdbPosterUrl(media.posterPath),
          backdropImageUrl: tmdbBackdropUrl(media.backdropPath),
          rating: media.voteAverage?.toDouble(),
          itemJson: jsonEncode(media.toJson()),
        );
  }

  void _saveBook(Book book) {
    final imageUrl =
        book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'];
    ref
        .read(libraryProvider.notifier)
        .addItem(
          externalId: book.id,
          mediaType: 'book',
          title: book.title,
          subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
          imageUrl: imageUrl,
          backdropImageUrl: imageUrl,
          rating: book.averageRating?.toDouble(),
          itemJson: jsonEncode(book.toJson()),
        );
  }

  void _saveGame(Game game) {
    ref
        .read(libraryProvider.notifier)
        .addItem(
          externalId: game.id.toString(),
          mediaType: 'game',
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

  void _showDetails(BuildContext context, Object entity) {
    showModalBottomSheet<void>(
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
            builder: (_, controller) =>
                MediaDetailModal(entity: entity, scrollController: controller),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryItems = ref.watch(libraryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.75, 0.95],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12122A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Text(
                      l10n.addToLibraryTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    CategoryTabItem(
                      label: l10n.filterMedia,
                      isSelected: _selectedCategory == DiscoverCategory.media,
                      onTap: () => setState(
                        () => _selectedCategory = DiscoverCategory.media,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CategoryTabItem(
                      label: l10n.filterBooks,
                      isSelected: _selectedCategory == DiscoverCategory.books,
                      onTap: () => setState(
                        () => _selectedCategory = DiscoverCategory.books,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CategoryTabItem(
                      label: l10n.filterGames,
                      isSelected: _selectedCategory == DiscoverCategory.games,
                      onTap: () => setState(
                        () => _selectedCategory = DiscoverCategory.games,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: l10n.addToLibrarySearchHint,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white54,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildResults(
                  context,
                  scrollController,
                  libraryItems,
                  l10n,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResults(
    BuildContext context,
    ScrollController scrollController,
    List<LibraryItem> libraryItems,
    AppLocalizations l10n,
  ) {
    Widget sliver;

    if (_query.isEmpty) {
      sliver = SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            l10n.addToLibrarySearchPrompt,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          ),
        ),
      );
    } else {
      final AsyncValue<List<Object>> asyncValue = switch (_selectedCategory) {
        DiscoverCategory.media =>
          ref
              .watch(searchMediaProvider(_query))
              .whenData((list) => list.cast<Object>()),
        DiscoverCategory.books =>
          ref
              .watch(searchBooksProvider(_query))
              .whenData((list) => list.cast<Object>()),
        DiscoverCategory.games =>
          ref
              .watch(searchGamesProvider(_query))
              .whenData((list) => list.cast<Object>()),
      };

      sliver = asyncValue.when(
        loading: () => const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) {
          debugPrint('AddToLibrarySheet search error: $e');
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.addToLibrarySearchError,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
        data: (results) {
          if (results.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  l10n.addToLibraryNoResults,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                ),
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: 32.0 + MediaQuery.paddingOf(context).bottom),
            sliver: SliverToBoxAdapter(
              child: _buildMasonryGrid(
                _buildCards(context, results, libraryItems),
              ),
            ),
          );
        },
      );
    }

    return CustomScrollView(controller: scrollController, slivers: [sliver]);
  }

  List<Widget> _buildCards(
    BuildContext context,
    List<Object> results,
    List<LibraryItem> libraryItems,
  ) {
    return results.map((entity) {
      return switch (entity) {
        Media media => _buildMediaCard(context, media, libraryItems),
        Book book => _buildBookCard(context, book, libraryItems),
        Game game => _buildGameCard(context, game, libraryItems),
        _ => const SizedBox.shrink(),
      };
    }).toList();
  }

  Widget _buildMediaCard(
    BuildContext context,
    Media media,
    List<LibraryItem> libraryItems,
  ) {
    final externalId = media.id.toString();
    final mediaType = _persistedMediaType(media.mediaType);
    final isSaved = libraryItems.any(
      (i) => i.externalId == externalId && i.mediaType == mediaType,
    );
    return MediaResultCard(
      title: media.title ?? media.name ?? '',
      mediaType: media.mediaType == MediaType.tv
          ? MediaCardType.tv
          : MediaCardType.movie,
      subtitle: _buildSubtitle(
        _extractYear(media.releaseDate),
        _formatRating(media.voteAverage),
      ),
      imageUrl: tmdbPosterUrl(media.posterPath),
      isSaved: isSaved,
      onTap: () => _showDetails(context, media),
      onSave: () => _saveMedia(media),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Book book,
    List<LibraryItem> libraryItems,
  ) {
    final isSaved = libraryItems.any(
      (i) => i.externalId == book.id && i.mediaType == 'book',
    );
    final imageUrl =
        book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'];
    return MediaResultCard(
      title: book.title,
      mediaType: MediaCardType.book,
      subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
      imageUrl: imageUrl,
      isSaved: isSaved,
      onTap: () => _showDetails(context, book),
      onSave: () => _saveBook(book),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    Game game,
    List<LibraryItem> libraryItems,
  ) {
    final isSaved = libraryItems.any(
      (i) => i.externalId == game.id.toString() && i.mediaType == 'game',
    );
    return MediaResultCard(
      title: game.name,
      mediaType: MediaCardType.game,
      subtitle: _buildSubtitle(
        _extractYear(game.released),
        _formatRating(game.rating ?? game.aggregatedRating),
      ),
      imageUrl: game.coverUrl,
      isSaved: isSaved,
      onTap: () => _showDetails(context, game),
      onSave: () => _saveGame(game),
    );
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
                padding: const EdgeInsets.only(bottom: 12.0),
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
        const SizedBox(width: 12),
        column(rightCards),
      ],
    );
  }
}
