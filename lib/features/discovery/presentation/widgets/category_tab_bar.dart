import 'package:flutter/material.dart';

import '../../domain/entities/discover_category.dart';

class CategoryTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTabItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryTabBar extends StatelessWidget {
  final String filterAllLabel;
  final String filterMediaLabel;
  final String filterBooksLabel;
  final String filterGamesLabel;

  final bool hasMedia;
  final bool hasBooks;
  final bool hasGames;

  final DiscoverCategory? selectedCategory;
  final ValueChanged<DiscoverCategory?> onCategorySelected;

  const CategoryTabBar({
    super.key,
    required this.filterAllLabel,
    required this.filterMediaLabel,
    required this.filterBooksLabel,
    required this.filterGamesLabel,
    required this.hasMedia,
    required this.hasBooks,
    required this.hasGames,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CategoryTabItem(
            label: filterAllLabel,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          if (hasMedia) ...[
            const SizedBox(width: 8),
            CategoryTabItem(
              label: filterMediaLabel,
              isSelected: selectedCategory == DiscoverCategory.media,
              onTap: () => onCategorySelected(DiscoverCategory.media),
            ),
          ],
          if (hasBooks) ...[
            const SizedBox(width: 8),
            CategoryTabItem(
              label: filterBooksLabel,
              isSelected: selectedCategory == DiscoverCategory.books,
              onTap: () => onCategorySelected(DiscoverCategory.books),
            ),
          ],
          if (hasGames) ...[
            const SizedBox(width: 8),
            CategoryTabItem(
              label: filterGamesLabel,
              isSelected: selectedCategory == DiscoverCategory.games,
              onTap: () => onCategorySelected(DiscoverCategory.games),
            ),
          ],
        ],
      ),
    );
  }
}
