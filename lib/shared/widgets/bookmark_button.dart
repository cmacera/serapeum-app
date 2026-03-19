import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class BookmarkButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback? onTap;
  final double size;

  const BookmarkButton({
    super.key,
    required this.isSaved,
    this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isSaved ? Icons.bookmark_added : Icons.bookmark_add,
        color: isSaved ? AppColors.accent : Colors.white,
        size: size,
        shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
      ),
    );
  }
}
