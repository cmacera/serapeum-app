import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class AgeRatingChip extends StatelessWidget {
  final String label;

  const AgeRatingChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const InfoSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title),
          const SizedBox(height: 8.0),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class TrailersSection extends StatelessWidget {
  final List<String> youtubeIds;

  const TrailersSection({super.key, required this.youtubeIds});

  Future<void> _launch(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (youtubeIds.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailTrailers),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: youtubeIds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) =>
                  _TrailerThumbnail(videoId: youtubeIds[index], onTap: _launch),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerThumbnail extends StatelessWidget {
  final String videoId;
  final Future<void> Function(String) onTap;

  const _TrailerThumbnail({required this.videoId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    return GestureDetector(
      onTap: () => onTap(videoId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 200,
          height: 112,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: theme.colorScheme.surfaceContainerHighest),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
