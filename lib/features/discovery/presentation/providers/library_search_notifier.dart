import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serapeum_app/core/enums/discover_category.dart';
import 'package:serapeum_app/core/localization/locale_provider.dart';
import 'package:serapeum_app/features/discovery/data/providers/discovery_providers.dart';

part 'library_search_notifier.g.dart';

class LibrarySearchState {
  final List<Object> items;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const LibrarySearchState({
    required this.items,
    required this.hasMore,
    required this.currentPage,
    required this.isLoadingMore,
  });

  const LibrarySearchState.empty()
    : items = const [],
      hasMore = false,
      currentPage = 0,
      isLoadingMore = false;

  LibrarySearchState copyWith({
    List<Object>? items,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return LibrarySearchState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class LibrarySearch extends _$LibrarySearch {
  // Synchronous guard to prevent multiple concurrent loadMore() requests
  // from firing between microtasks before state reflects isLoadingMore.
  bool _isLoadingMore = false;

  // Locale captured once per build so _fetchPage never calls ref outside build().
  late String _language;

  @override
  Future<LibrarySearchState> build(
    String query,
    DiscoverCategory category,
  ) async {
    _language = ref.watch(localeProvider);

    if (query.isEmpty) return const LibrarySearchState.empty();

    final page = await _fetchPage(1);
    return LibrarySearchState(
      items: page.items,
      hasMore: page.hasMore,
      currentPage: 1,
      isLoadingMore: false,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = await _fetchPage(current.currentPage + 1);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...nextPage.items],
          hasMore: nextPage.hasMore,
          currentPage: current.currentPage + 1,
          isLoadingMore: false,
        ),
      );
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<({List<Object> items, bool hasMore})> _fetchPage(int page) {
    final repo = ref.read(catalogSearchRepositoryProvider);
    return switch (category) {
      DiscoverCategory.media =>
        repo
            .searchMedia(query, language: _language, page: page)
            .then((r) => (items: r.results.cast<Object>(), hasMore: r.hasMore)),
      DiscoverCategory.books =>
        repo
            .searchBooks(query, language: _language, page: page)
            .then((r) => (items: r.results.cast<Object>(), hasMore: r.hasMore)),
      DiscoverCategory.games =>
        repo
            .searchGames(query, language: _language, page: page)
            .then((r) => (items: r.results.cast<Object>(), hasMore: r.hasMore)),
    };
  }
}
