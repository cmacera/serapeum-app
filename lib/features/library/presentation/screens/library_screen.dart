import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../discovery/domain/entities/book.dart';
import '../../../discovery/domain/entities/game.dart';
import '../../../discovery/domain/entities/media.dart';
import '../../../../core/enums/discover_category.dart';
import '../../../../core/enums/media_card_type.dart';
import '../../../../shared/widgets/category_tab_bar.dart';
import '../../../../shared/widgets/media_detail_modal.dart';
import '../../../../shared/widgets/media_result_card.dart';
import '../../data/local/library_item.dart';
import '../../data/providers/library_filter_provider.dart';
import '../../data/providers/library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  DiscoverCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allItems = ref.watch(libraryProvider);
    final sortOption = ref.watch(librarySortProvider);
    final searchQuery = ref.watch(librarySearchQueryProvider);

    final hasMedia = allItems.any(
      (i) => i.mediaType == 'movie' || i.mediaType == 'tv',
    );
    final hasBooks = allItems.any((i) => i.mediaType == 'book');
    final hasGames = allItems.any((i) => i.mediaType == 'game');

    int categoriesWithItems = 0;
    if (hasMedia) categoriesWithItems++;
    if (hasBooks) categoriesWithItems++;
    if (hasGames) categoriesWithItems++;
    final showTabs = categoriesWithItems >= 2;

    // Validate selected category
    if (_selectedCategory != null) {
      final stillValid = switch (_selectedCategory!) {
        DiscoverCategory.media => hasMedia,
        DiscoverCategory.books => hasBooks,
        DiscoverCategory.games => hasGames,
      };
      if (!stillValid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedCategory = null);
        });
      }
    }

    final trimmedQuery = searchQuery.trim();
    final hasSearchTerm = trimmedQuery.isNotEmpty;

    final filtered = _filterItems(allItems);
    final searched = _searchItems(filtered, trimmedQuery);
    final sorted = _sortItems(searched, sortOption);
    final cards = _buildCards(context, sorted);

    return CustomScrollView(
      slivers: [
        if (showTabs && allItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: CategoryTabBar(
                filterAllLabel: l10n.filterAll,
                filterMediaLabel: l10n.filterMedia,
                filterBooksLabel: l10n.filterBooks,
                filterGamesLabel: l10n.filterGames,
                hasMedia: hasMedia,
                hasBooks: hasBooks,
                hasGames: hasGames,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
            ),
          ),
        if (allItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_add_outlined,
                      size: 64,
                      color: AppColors.subtitle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.libraryEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.subtitle, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (sorted.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasSearchTerm ? Icons.search_off : Icons.filter_list_off,
                      size: 48,
                      color: AppColors.subtitle,
                    ),
                    if (hasSearchTerm) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.libraryNoSearchResults,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
              top: showTabs ? 8.0 : 16.0,
              bottom: 32.0 + MediaQuery.paddingOf(context).bottom,
            ),
            sliver: SliverToBoxAdapter(child: _buildMasonryGrid(cards)),
          ),
      ],
    );
  }

  // Expects a pre-trimmed query; callers are responsible for trimming.
  List<LibraryItem> _searchItems(List<LibraryItem> items, String query) {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((i) {
      return i.title.toLowerCase().contains(q) ||
          (i.subtitle?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<LibraryItem> _filterItems(List<LibraryItem> items) {
    if (_selectedCategory == null) return items;
    return items.where((i) {
      return switch (_selectedCategory!) {
        DiscoverCategory.media => i.mediaType == 'movie' || i.mediaType == 'tv',
        DiscoverCategory.books => i.mediaType == 'book',
        DiscoverCategory.games => i.mediaType == 'game',
      };
    }).toList();
  }

  List<LibraryItem> _sortItems(
    List<LibraryItem> items,
    LibrarySortOption option,
  ) {
    final copy = List<LibraryItem>.from(items);
    switch (option) {
      case LibrarySortOption.dateDesc:
        copy.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case LibrarySortOption.dateAsc:
        copy.sort((a, b) => a.addedAt.compareTo(b.addedAt));
      case LibrarySortOption.titleAsc:
        copy.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case LibrarySortOption.ratingDesc:
        copy.sort((a, b) {
          final ra = a.rating ?? -1;
          final rb = b.rating ?? -1;
          return rb.compareTo(ra);
        });
      case LibrarySortOption.byType:
        copy.sort((a, b) => a.mediaType.compareTo(b.mediaType));
    }
    return copy;
  }

  Object? _reconstructEntity(LibraryItem item) {
    try {
      final json = jsonDecode(item.itemJson) as Map<String, dynamic>;
      return switch (item.mediaType) {
        'movie' || 'tv' => Media.fromJson(json),
        'book' => Book.fromJson(json),
        'game' => Game.fromJson(json),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  void _showLibraryDetails(BuildContext context, LibraryItem item) {
    final entity = _reconstructEntity(item);
    if (entity == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
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
  }

  List<Widget> _buildCards(BuildContext context, List<LibraryItem> items) {
    return items.map((item) {
      final cardType = switch (item.mediaType) {
        'tv' => MediaCardType.tv,
        'book' => MediaCardType.book,
        'game' => MediaCardType.game,
        _ => MediaCardType.movie,
      };
      return MediaResultCard(
        title: item.title,
        mediaType: cardType,
        subtitle: item.subtitle,
        imageUrl: item.imageUrl,
        onTap: () => _showLibraryDetails(context, item),
        isConsumed: item.isConsumed,
      );
    }).toList();
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
}
