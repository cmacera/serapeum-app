import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import 'package:serapeum_app/core/presentation/widgets/particle_background.dart';

import 'package:serapeum_app/features/discovery/data/local/discover_history_item.dart';
import 'package:serapeum_app/features/discovery/data/models/orchestrator_response_dto.dart';
import 'package:serapeum_app/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:serapeum_app/features/discovery/presentation/screens/discovery_history_screen.dart';
import 'package:serapeum_app/features/library/data/providers/library_filter_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _resetSearchState() {
    setState(() => _isSearchActive = false);
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(librarySearchQueryProvider.notifier).state = '';
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
            widget.navigationShell.currentIndex &&
        oldWidget.navigationShell.currentIndex == 0 &&
        _isSearchActive) {
      _resetSearchState();
    }
  }

  void _showSortSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12122A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  child: Text(
                    l10n.sortOptions,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final option in LibrarySortOption.values)
                  ListTile(
                    leading: Icon(
                      _sortOptionIcon(option),
                      color: AppColors.accent,
                    ),
                    title: Text(
                      _sortOptionLabel(option, l10n),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      ref.read(librarySortProvider.notifier).state = option;
                      Navigator.pop(sheetContext);
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _sortOptionIcon(LibrarySortOption option) => switch (option) {
    LibrarySortOption.dateDesc => Icons.schedule,
    LibrarySortOption.dateAsc => Icons.history,
    LibrarySortOption.titleAsc => Icons.sort_by_alpha,
    LibrarySortOption.ratingDesc => Icons.star,
    LibrarySortOption.byType => Icons.category_outlined,
  };

  String _sortOptionLabel(LibrarySortOption option, AppLocalizations l10n) =>
      switch (option) {
        LibrarySortOption.dateDesc => l10n.sortByDateDesc,
        LibrarySortOption.dateAsc => l10n.sortByDateAsc,
        LibrarySortOption.titleAsc => l10n.sortByTitle,
        LibrarySortOption.ratingDesc => l10n.sortByRating,
        LibrarySortOption.byType => l10n.sortByType,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = widget.navigationShell.currentIndex;

    final String subtitle = switch (currentIndex) {
      0 => l10n.myLibraryTitle,
      1 => l10n.discoverTitle,
      2 => l10n.controlCenterTitle,
      _ => '',
    };

    final bool showSearchField = currentIndex == 0 && _isSearchActive;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF06061A), // Dark navy base
            Color(0xFF0A0414), // Deep space transition
            Color(0xFF2B0B55), // Vibrant deep purple accent in the corner
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the gradient shine through
        appBar: AppBar(
          centerTitle: false,
          title: showSearchField
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: l10n.searchLibraryHint,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    ref.read(librarySearchQueryProvider.notifier).state = value;
                  },
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
          backgroundColor: Colors.transparent, // Let gradient shine through
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            if (currentIndex == 0) ...[
              if (_isSearchActive)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: l10n.close,
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                    });
                    _searchController.clear();
                    ref.read(librarySearchQueryProvider.notifier).state = '';
                  },
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = true;
                    });
                    _searchFocusNode.requestFocus();
                  },
                  tooltip: l10n.searchLibraryTooltip,
                ),
                IconButton(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onPressed: () => _showSortSheet(context, l10n),
                  tooltip: l10n.sortOptions,
                ),
              ],
            ],
            if (widget.navigationShell.currentIndex == 1) ...[
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  ref.read(discoveryProvider.notifier).startNewConversation();
                },
                tooltip: l10n.newConversation,
              ),
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                onPressed: () async {
                  final historyItem =
                      await showModalBottomSheet<DiscoverHistoryItem>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        useRootNavigator: true,
                        builder: (context) => const DiscoveryHistoryScreen(),
                      );

                  if (historyItem != null && context.mounted) {
                    try {
                      final cached = OrchestratorResponseDto.mapToDomain(
                        jsonDecode(historyItem.resultJson),
                      );
                      ref
                          .read(discoveryProvider.notifier)
                          .loadCachedResult(historyItem.query, cached);
                    } catch (e) {
                      debugPrint('Failed to restore history item: $e');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.queryFailed)),
                        );
                      }
                    }
                  }
                },
                tooltip: l10n.discoveryHistoryTitle,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: ParticleBackground()),
            widget.navigationShell,
          ],
        ),
        extendBody: true,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 56.0,
              vertical: 0.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                borderRadius: BorderRadius.circular(32),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: NavigationBar(
                  height: 60,
                  selectedIndex: widget.navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    if (widget.navigationShell.currentIndex == 0 &&
                        index != 0 &&
                        _isSearchActive) {
                      _resetSearchState();
                    }
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  indicatorColor: Colors.transparent, // Removed overlay
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.library_books_outlined),
                      selectedIcon: const Icon(
                        Icons.library_books,
                        color: AppColors.accent,
                      ),
                      label: l10n.myLibraryTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.auto_awesome_outlined),
                      selectedIcon: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                      ),
                      label: l10n.discoverTitle,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(
                        Icons.settings,
                        color: AppColors.accent,
                      ),
                      label: l10n.controlCenterTitle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
