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
import 'package:serapeum_app/features/discovery/presentation/providers/library_search_notifier.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';
import 'package:serapeum_app/features/library/data/providers/library_provider.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:serapeum_app/shared/widgets/category_tab_bar.dart';
import 'package:serapeum_app/shared/widgets/media_detail_modal.dart';
import 'package:serapeum_app/shared/widgets/media_result_card.dart';

// How many pixels before the bottom edge triggers the next-page load.
const double _kLoadMoreThreshold = 200.0;

// Sheet and modal snap sizes.
const double _kSheetInitialSize = 0.75;
const double _kSheetMinSize = 0.4;
const double _kSheetMaxSize = 0.95;
const double _kDetailModalInitialSize = 0.9;
const double _kDetailModalMinSize = 0.4;

// Background colour for the sheet surface — matches the dark-space theme.
const Color _kSheetBackground = Color(0xFF12122A);

class AddToLibrarySheet extends ConsumerStatefulWidget {
  const AddToLibrarySheet({super.key});

  @override
  ConsumerState<AddToLibrarySheet> createState() => _AddToLibrarySheetState();
}

class _AddToLibrarySheetState extends ConsumerState<AddToLibrarySheet> {
  DiscoverCategory _selectedCategory = DiscoverCategory.media;
  String _query = '';
  final TextEditingController _textController = TextEditingController();
  ScrollController? _scrollController;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  /// Schedules a post-frame underflow check: if after the first page renders
  /// the content doesn't fill the viewport, load the next page automatically.
  void _scheduleUnderflowCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _scrollController;
      if (controller == null || !controller.hasClients) return;
      final pos = controller.position;
      if (pos.maxScrollExtent - pos.pixels < _kLoadMoreThreshold) {
        ref
            .read(librarySearchProvider(_query, _selectedCategory).notifier)
            .loadMore();
      }
    });
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

  String? _bookImageUrl(Book book) =>
      book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'];

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
    final imageUrl = _bookImageUrl(book);
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
            initialChildSize: _kDetailModalInitialSize,
            minChildSize: _kDetailModalMinSize,
            maxChildSize: _kSheetMaxSize,
            snap: true,
            snapSizes: const [_kDetailModalInitialSize],
            shouldCloseOnMinExtent: true,
            builder: (_, controller) =>
                MediaDetailModal(entity: entity, scrollController: controller),
          ),
        );
      },
    );
  }

  /// Builds a Set of "mediaType:externalId" keys for O(1) saved-item lookup.
  Set<String> _savedKeys(List<LibraryItem> items) => {
    for (final i in items) '${i.mediaType}:${i.externalId}',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraryItems = ref.watch(libraryProvider);
    final savedKeys = _savedKeys(libraryItems);

    return DraggableScrollableSheet(
      initialChildSize: _kSheetInitialSize,
      minChildSize: _kSheetMinSize,
      maxChildSize: _kSheetMaxSize,
      snap: true,
      snapSizes: const [_kSheetInitialSize, _kSheetMaxSize],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: _kSheetBackground,
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
                  savedKeys,
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
    Set<String> savedKeys,
    AppLocalizations l10n,
  ) {
    _scrollController = scrollController;

    if (_query.isEmpty) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l10n.addToLibrarySearchPrompt,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      );
    }

    final asyncState = ref.watch(
      librarySearchProvider(_query, _selectedCategory),
    );

    // Underflow check: if the first page doesn't fill the viewport, no scroll
    // events will fire. Listen for data transitions and trigger loadMore if
    // the content height is below the scroll threshold.
    ref.listen(librarySearchProvider(_query, _selectedCategory), (_, next) {
      if (next.valueOrNull?.currentPage == 1 &&
          (next.valueOrNull?.hasMore ?? false)) {
        _scheduleUnderflowCheck();
      }
    });

    return NotificationListener<ScrollUpdateNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        if (metrics.pixels >= metrics.maxScrollExtent - _kLoadMoreThreshold) {
          ref
              .read(librarySearchProvider(_query, _selectedCategory).notifier)
              .loadMore();
        }
        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          ...asyncState.when(
            loading: () => [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (e, _) {
              debugPrint('AddToLibrarySheet search error: $e');
              return [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        l10n.addToLibrarySearchError,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ];
            },
            data: (searchState) {
              if (searchState.items.isEmpty) {
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        l10n.addToLibraryNoResults,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ];
              }
              return [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverToBoxAdapter(
                    child: _buildMasonryGrid(
                      _buildCards(context, searchState.items, savedKeys),
                    ),
                  ),
                ),
                if (searchState.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 32.0 + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCards(
    BuildContext context,
    List<Object> results,
    Set<String> savedKeys,
  ) {
    return results.map((entity) {
      return switch (entity) {
        Media media => _buildMediaCard(context, media, savedKeys),
        Book book => _buildBookCard(context, book, savedKeys),
        Game game => _buildGameCard(context, game, savedKeys),
        _ => const SizedBox.shrink(),
      };
    }).toList();
  }

  Widget _buildMediaCard(
    BuildContext context,
    Media media,
    Set<String> savedKeys,
  ) {
    final mediaType = _persistedMediaType(media.mediaType);
    final isSaved = savedKeys.contains('$mediaType:${media.id}');
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
      onSave: isSaved
          ? () => ref
                .read(libraryProvider.notifier)
                .removeItem(media.id.toString(), mediaType)
          : () => _saveMedia(media),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Book book,
    Set<String> savedKeys,
  ) {
    final isSaved = savedKeys.contains('book:${book.id}');
    return MediaResultCard(
      title: book.title,
      mediaType: MediaCardType.book,
      subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
      imageUrl: _bookImageUrl(book),
      isSaved: isSaved,
      onTap: () => _showDetails(context, book),
      onSave: isSaved
          ? () => ref.read(libraryProvider.notifier).removeItem(book.id, 'book')
          : () => _saveBook(book),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    Game game,
    Set<String> savedKeys,
  ) {
    final isSaved = savedKeys.contains('game:${game.id}');
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
      onSave: isSaved
          ? () => ref
                .read(libraryProvider.notifier)
                .removeItem(game.id.toString(), 'game')
          : () => _saveGame(game),
    );
  }

  Widget _buildMasonryGrid(List<Widget> cards) {
    final leftCards = <Widget>[];
    final rightCards = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      (i.isEven ? leftCards : rightCards).add(cards[i]);
    }

    Widget column(List<Widget> items) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final w in items)
            Padding(padding: const EdgeInsets.only(bottom: 12.0), child: w),
        ],
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
