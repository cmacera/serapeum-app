import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/media_card_type.dart';
import 'bookmark_button.dart';

class MediaResultCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final MediaCardType mediaType;
  final VoidCallback? onTap;
  final bool? isSaved;
  final VoidCallback? onSave;
  final bool? isConsumed;

  const MediaResultCard({
    super.key,
    required this.title,
    required this.mediaType,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.isSaved,
    this.onSave,
    this.isConsumed,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
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
                    top: 6,
                    left: 6,
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

    if (isSaved == null) return card;

    return Stack(
      children: [
        card,
        Positioned(
          top: 4,
          right: 4,
          child: BookmarkButton(isSaved: isSaved!, onTap: onSave),
        ),
      ],
    );
  }

  double get _imageAspectRatio => switch (mediaType) {
    MediaCardType.movie => 2 / 3,
    MediaCardType.tv => 2 / 3,
    MediaCardType.book => 2 / 3,
    MediaCardType.game => 3 / 4,
  };

  IconData get _typeIcon => switch (mediaType) {
    MediaCardType.movie => Icons.movie,
    MediaCardType.tv => Icons.tv,
    MediaCardType.book => Icons.import_contacts,
    MediaCardType.game => Icons.sports_esports,
  };

  Color get _badgeColor => switch (mediaType) {
    MediaCardType.movie => AppColors.badgeMedia,
    MediaCardType.tv => AppColors.badgeMedia,
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 22, color: Colors.white),
    );
  }
}
