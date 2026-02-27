import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
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

  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

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
              isSelected: selectedCategory == 'Media',
              onTap: () => onCategorySelected('Media'),
            ),
          ],
          if (hasBooks) ...[
            const SizedBox(width: 8),
            CategoryTabItem(
              label: filterBooksLabel,
              isSelected: selectedCategory == 'Books',
              onTap: () => onCategorySelected('Books'),
            ),
          ],
          if (hasGames) ...[
            const SizedBox(width: 8),
            CategoryTabItem(
              label: filterGamesLabel,
              isSelected: selectedCategory == 'Games',
              onTap: () => onCategorySelected('Games'),
            ),
          ],
        ],
      ),
    );
  }
}
