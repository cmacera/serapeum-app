import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum MediaCardType { movie, tv, book, game }

class MediaResultCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final MediaCardType mediaType;
  final VoidCallback? onTap;

  const MediaResultCard({
    super.key,
    required this.title,
    required this.mediaType,
    this.subtitle,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _imageAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.thumbnailBackground,
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                _typeIcon,
                                color: AppColors.iconFallback,
                                size: 40,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              _typeIcon,
                              color: AppColors.iconFallback,
                              size: 40,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _TypeBadge(icon: _typeIcon, color: _badgeColor),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 11, color: AppColors.subtitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _imageAspectRatio => switch (mediaType) {
    MediaCardType.movie => 2 / 3,
    MediaCardType.tv => 2 / 3,
    MediaCardType.book => 2 / 3,
    MediaCardType.game => 3 / 4,
  };

  IconData get _typeIcon => switch (mediaType) {
    MediaCardType.movie => Icons.movie_outlined,
    MediaCardType.tv => Icons.tv_outlined,
    MediaCardType.book => Icons.menu_book_outlined,
    MediaCardType.game => Icons.sports_esports_outlined,
  };

  Color get _badgeColor => switch (mediaType) {
    MediaCardType.movie => AppColors.accent,
    MediaCardType.tv => AppColors.badgeTv,
    MediaCardType.book => AppColors.badgeBook,
    MediaCardType.game => AppColors.badgeGame,
  };
}

class _TypeBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TypeBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 14, color: Colors.white),
    );
  }
}
