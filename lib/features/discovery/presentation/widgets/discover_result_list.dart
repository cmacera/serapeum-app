import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/featured_item.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/media.dart';
import '../../domain/entities/search_all_response.dart';
import '../../../library/data/local/library_item.dart';
import '../../../library/data/providers/library_provider.dart';
import '../../../../core/enums/discover_category.dart';
import '../../../../core/enums/media_card_type.dart';
import '../../../../core/utils/tmdb_image_utils.dart';
import '../../../../shared/utils/remove_from_library_dialog.dart';
import '../../../../shared/widgets/category_tab_bar.dart';
import '../../../../shared/widgets/media_detail_modal.dart';
import '../../../../shared/widgets/media_result_card.dart';
import 'chat_message_bubble.dart';
import 'feedback_buttons.dart';

class DiscoverResultList extends ConsumerStatefulWidget {
  final String query;
  final String assistantText;
  final SearchAllResponse response;
  final String? traceId;

  const DiscoverResultList({
    super.key,
    required this.query,
    required this.assistantText,
    required this.response,
    this.traceId,
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

  String _persistedMediaType(MediaType type) =>
      type == MediaType.tv ? 'tv' : 'movie';

  (String externalId, String mediaType) _entityKey(Object entity) =>
      switch (entity) {
        Media m => (m.id.toString(), _persistedMediaType(m.mediaType)),
        Book b => (b.id, 'book'),
        Game g => (g.id.toString(), 'game'),
        _ => throw ArgumentError('Unknown entity type: $entity'),
      };

  LibraryItem? _savedItemForEntity(List<LibraryItem> items, Object entity) {
    final (externalId, mediaType) = _entityKey(entity);
    return items
        .where((i) => i.externalId == externalId && i.mediaType == mediaType)
        .firstOrNull;
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
        showRemoveFromLibraryDialog(
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
        imageUrl: tmdbPosterUrl(media.posterPath),
        backdropImageUrl: tmdbBackdropUrl(media.backdropPath),
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
        showRemoveFromLibraryDialog(
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
        showRemoveFromLibraryDialog(
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

  Widget _buildCategoryTabBar(
    AppLocalizations l10n,
    bool hasMedia,
    bool hasBooks,
    bool hasGames,
  ) => CategoryTabBar(
    filterAllLabel: l10n.filterAll,
    filterMediaLabel: l10n.filterMedia,
    filterBooksLabel: l10n.filterBooks,
    filterGamesLabel: l10n.filterGames,
    hasMedia: hasMedia,
    hasBooks: hasBooks,
    hasGames: hasGames,
    selectedCategory: _selectedCategory,
    onCategorySelected: (category) =>
        setState(() => _selectedCategory = category),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.response;
    final libraryItems = ref.watch(libraryProvider);
    final wide = ResponsiveLayout.isWide(context);

    final hasMedia = data.media.isNotEmpty;
    final hasBooks = data.books.isNotEmpty;
    final hasGames = data.games.isNotEmpty;

    final hasResults =
        hasMedia || hasBooks || hasGames || data.featured != null;
    final showTabs = [hasMedia, hasBooks, hasGames].where((b) => b).length >= 2;

    final cards = _buildFilteredCards(context, l10n, data, libraryItems);
    final bottomPadding = 32.0 + MediaQuery.paddingOf(context).bottom;

    final headerColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChatMessageBubble(text: widget.query, isUser: true),
        const SizedBox(height: 16),
        ChatMessageBubble(text: widget.assistantText, isUser: false),
        FeedbackButtons(traceId: widget.traceId),
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
    );

    if (wide && data.featured != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: headerColumn,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0x14FFFFFF)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ResponsiveLayout.featuredPanelWidth,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildFeaturedCard(
                      context,
                      data.featured!,
                      libraryItems,
                      l10n,
                    ),
                  ),
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: AppColors.subtleDivider,
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      if (showTabs && hasResults)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildCategoryTabBar(
                              l10n,
                              hasMedia,
                              hasBooks,
                              hasGames,
                            ),
                          ),
                        ),
                      if (cards.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ).copyWith(top: 16.0, bottom: bottomPadding),
                          sliver: SliverToBoxAdapter(
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  _buildMasonryGrid(
                                    cards,
                                    ResponsiveLayout.gridColumnCount(
                                      constraints.maxWidth,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Narrow or wide without featured: single scroll view
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerColumn,
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
                  _buildCategoryTabBar(l10n, hasMedia, hasBooks, hasGames),
                ],
              ],
            ),
          ),
        ),
        if (cards.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(bottom: bottomPadding),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) => _buildMasonryGrid(
                  cards,
                  ResponsiveLayout.gridColumnCount(constraints.maxWidth),
                ),
              ),
            ),
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
            builder: (_, controller) =>
                MediaDetailModal(entity: entity, scrollController: controller),
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
  ) {
    final savedItem = _savedItemForEntity(libraryItems, media);
    return MediaResultCard(
      title: media.title ?? media.name ?? l10n.unknownMedia,
      mediaType: media.mediaType == MediaType.tv
          ? MediaCardType.tv
          : MediaCardType.movie,
      subtitle: _buildSubtitle(
        _extractYear(media.releaseDate),
        _formatRating(media.voteAverage),
      ),
      imageUrl: tmdbPosterUrl(media.posterPath),
      onTap: () => _showDetails(context, media),
      isSaved: savedItem != null,
      isConsumed: savedItem?.isConsumed,
      onSave: () => _toggleSaveMedia(context, media),
    );
  }

  MediaResultCard _buildBookCard(
    BuildContext context,
    Book book,
    List<LibraryItem> libraryItems,
  ) {
    final savedItem = _savedItemForEntity(libraryItems, book);
    return MediaResultCard(
      title: book.title,
      mediaType: MediaCardType.book,
      subtitle: _buildSubtitle(_extractYear(book.publishedDate), null),
      imageUrl:
          book.imageLinks?['thumbnail'] ?? book.imageLinks?['smallThumbnail'],
      onTap: () => _showDetails(context, book),
      isSaved: savedItem != null,
      isConsumed: savedItem?.isConsumed,
      onSave: () => _toggleSaveBook(context, book),
    );
  }

  MediaResultCard _buildGameCard(
    BuildContext context,
    Game game,
    List<LibraryItem> libraryItems,
  ) {
    final savedItem = _savedItemForEntity(libraryItems, game);
    return MediaResultCard(
      title: game.name,
      mediaType: MediaCardType.game,
      subtitle: _buildSubtitle(
        _extractYear(game.released),
        _formatRating(game.rating ?? game.aggregatedRating),
      ),
      imageUrl: game.coverUrl,
      onTap: () => _showDetails(context, game),
      isSaved: savedItem != null,
      isConsumed: savedItem?.isConsumed,
      onSave: () => _toggleSaveGame(context, game),
    );
  }

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
  ) => _FeaturedHalo(
    child: switch (featured) {
      FeaturedMedia(:final media) => _buildMediaCard(
        context,
        media,
        libraryItems,
        l10n,
      ),
      FeaturedBook(:final book) => _buildBookCard(context, book, libraryItems),
      FeaturedGame(:final game) => _buildGameCard(context, game, libraryItems),
    },
  );

  Widget _buildMasonryGrid(List<Widget> cards, int columns) {
    final cols = List.generate(columns, (_) => <Widget>[]);
    for (int i = 0; i < cards.length; i++) {
      cols[i % columns].add(cards[i]);
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
        for (int i = 0; i < columns; i++) ...[
          column(cols[i]),
          if (i < columns - 1) const SizedBox(width: 16),
        ],
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

// ---------------------------------------------------------------------------
// Shimmering halo wrapper for the featured card
// ---------------------------------------------------------------------------

class _FeaturedHalo extends StatefulWidget {
  const _FeaturedHalo({required this.child});
  final Widget child;

  @override
  State<_FeaturedHalo> createState() => _FeaturedHaloState();
}

class _FeaturedHaloState extends State<_FeaturedHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _HaloPainter(progress: _controller.value),
        child: child,
      ),
      child: Padding(padding: const EdgeInsets.all(3.0), child: widget.child),
    );
  }
}

class _HaloPainter extends CustomPainter {
  const _HaloPainter({required this.progress});
  final double progress;

  // Matches MediaResultCard's BorderRadius.circular(16) + 2px halo inset
  static const _radius = 18.0;
  static const _inset = 1.5;
  static const _strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _inset,
      _inset,
      size.width - _inset * 2,
      size.height - _inset * 2,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_radius));

    // Soft pulsing outer glow
    final glowAlpha = 0.25 + 0.15 * math.sin(2 * math.pi * progress);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF930DF2).withValues(alpha: glowAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth * 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
    );

    // Rotating sweep gradient stroke
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = SweepGradient(
          colors: const [
            Colors.transparent,
            Color(0xFF930DF2),
            Color(0xFFB060FF),
            Color(0xFF60C8FF),
            Color(0xFF930DF2),
            Colors.transparent,
          ],
          stops: const [0.0, 0.15, 0.4, 0.6, 0.8, 1.0],
          transform: GradientRotation(2 * math.pi * progress),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_HaloPainter old) => old.progress != progress;
}
