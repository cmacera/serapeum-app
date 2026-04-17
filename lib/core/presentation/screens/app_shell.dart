import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/layout_constants.dart';
import 'package:serapeum_app/core/presentation/widgets/particle_background.dart';
import 'package:serapeum_app/features/library/presentation/widgets/add_to_library_sheet.dart';

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

  void _onNavTap(int index) {
    if (widget.navigationShell.currentIndex == 0 &&
        index != 0 &&
        _isSearchActive) {
      _resetSearchState();
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = widget.navigationShell.currentIndex;
    final wide = ResponsiveLayout.isWide(context);

    final String subtitle = switch (currentIndex) {
      0 => l10n.myLibraryTitle,
      1 => l10n.discoverTitle,
      2 => l10n.controlCenterTitle,
      _ => '',
    };

    final bool showSearchField = currentIndex == 0 && _isSearchActive;

    final appBar = AppBar(
      centerTitle: false,
      title: showSearchField
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: wide
                    ? ResponsiveLayout.contentMaxWidth
                    : double.infinity,
              ),
              child: TextField(
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
              ),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      actions: [
        if (currentIndex == 0) ...[
          if (_isSearchActive)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              tooltip: l10n.close,
              onPressed: _resetSearchState,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearchActive = true;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchFocusNode.requestFocus();
                });
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
        if (currentIndex == 1) ...[
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.queryFailed)));
                  }
                }
              }
            },
            tooltip: l10n.discoveryHistoryTitle,
          ),
          const SizedBox(width: 8),
        ],
      ],
    );

    final fab = currentIndex == 0 && !_isSearchActive
        ? FloatingActionButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddToLibrarySheet(),
            ),
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            tooltip: l10n.addToLibraryTitle,
            child: const Icon(Icons.add),
          )
        : null;

    final contentStack = Stack(
      children: [
        const Positioned.fill(child: ParticleBackground()),
        widget.navigationShell,
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06061A), Color(0xFF0A0414), Color(0xFF2B0B55)],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        floatingActionButton: fab,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        extendBody: !wide,
        body: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: _onNavTap,
                    backgroundColor: Colors.transparent,
                    labelType: NavigationRailLabelType.none,
                    indicatorColor: AppColors.accent.withValues(alpha: 0.15),
                    destinations: _navItems(l10n)
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(
                              item.selectedIcon,
                              color: AppColors.accent,
                            ),
                            label: Text(item.label),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: AppColors.subtleDivider,
                  ),
                  Expanded(child: contentStack),
                ],
              )
            : contentStack,
        bottomNavigationBar: wide
            ? null
            : SafeArea(
                minimum: const EdgeInsets.only(bottom: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56.0),
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
                        selectedIndex: currentIndex,
                        onDestinationSelected: _onNavTap,
                        labelBehavior:
                            NavigationDestinationLabelBehavior.alwaysHide,
                        indicatorColor: Colors.transparent,
                        destinations: _navItems(l10n)
                            .map(
                              (item) => NavigationDestination(
                                icon: Icon(item.icon),
                                selectedIcon: Icon(
                                  item.selectedIcon,
                                  color: AppColors.accent,
                                ),
                                label: item.label,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared nav item definition — single source of truth for both NavigationRail
// and NavigationBar destinations.
// ---------------------------------------------------------------------------

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

List<_NavItem> _navItems(AppLocalizations l10n) => [
  _NavItem(
    icon: Icons.bookmarks_outlined,
    selectedIcon: Icons.bookmarks,
    label: l10n.myLibraryTitle,
  ),
  _NavItem(
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
    label: l10n.discoverTitle,
  ),
  _NavItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: l10n.controlCenterTitle,
  ),
];
