import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/media.dart';
import 'detail_sections/book_info_section.dart';
import 'detail_sections/game_info_section.dart';
import 'detail_sections/media_info_section.dart';

class DiscoverDetailModal extends StatelessWidget {
  final Object entity;
  final ScrollController? scrollController;

  const DiscoverDetailModal({
    super.key,
    required this.entity,
    this.scrollController,
  }) : assert(entity is Media || entity is Book || entity is Game);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      child: Material(
        color: theme.colorScheme.surface,
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            _buildImmersiveHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaStats(context),
                    const SizedBox(height: 24.0),
                    _buildSynopsis(context),
                    const SizedBox(height: 24.0),
                    _buildSpecializedInfo(context),
                    SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 24.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    if (entity is Media) {
      return (entity as Media).title ??
          (entity as Media).name ??
          l10n.unknownMedia;
    }
    if (entity is Book) return (entity as Book).title;
    if (entity is Game) return (entity as Game).name;
    return l10n.detailDefaultTitle;
  }

  String? _getBackdropUrl() {
    if (entity is Media) {
      final m = entity as Media;
      if (m.backdropPath != null && m.backdropPath!.isNotEmpty) {
        return '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW780}${m.backdropPath}';
      }
      if (m.posterPath != null && m.posterPath!.isNotEmpty) {
        return '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}${m.posterPath}';
      }
      return null;
    }
    if (entity is Book) {
      return (entity as Book).imageLinks?['thumbnail'] ??
          (entity as Book).imageLinks?['smallThumbnail'];
    }
    if (entity is Game) {
      return (entity as Game).coverUrl;
    }
    return null;
  }

  Widget _buildImmersiveHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = _getTitle(l10n);
    final backdropUrl = _getBackdropUrl();

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // Background Image
          if (backdropUrl != null)
            Image.network(
              backdropUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 200,
              color: theme.colorScheme.surfaceContainerHighest,
            ),

          // Gradient Overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.7),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),

          // Title
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Drag handle overlay
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 10,
            left: 12,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(32, 32),
              ),
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaStats(BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> chips = [];

    void addChip(IconData icon, String text) {
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (entity is Media) {
      final media = entity as Media;
      if (media.releaseDate != null && media.releaseDate!.length >= 4) {
        addChip(Icons.calendar_today, media.releaseDate!.substring(0, 4));
      }
      if (media.voteAverage != null && media.voteAverage! > 0) {
        addChip(Icons.star, media.voteAverage!.toStringAsFixed(1));
      }
      if (media.originalLanguage != null &&
          media.originalLanguage!.isNotEmpty) {
        addChip(Icons.language, media.originalLanguage!.toUpperCase());
      }
    } else if (entity is Book) {
      final book = entity as Book;
      if (book.publishedDate != null && book.publishedDate!.length >= 4) {
        addChip(Icons.calendar_today, book.publishedDate!.substring(0, 4));
      }
      if (book.pageCount != null) {
        addChip(Icons.auto_stories, '${book.pageCount} p.');
      }
      if (book.averageRating != null && book.averageRating! > 0) {
        addChip(Icons.star, book.averageRating!.toStringAsFixed(1));
      }
    } else if (entity is Game) {
      final game = entity as Game;
      if (game.released != null && game.released!.length >= 4) {
        addChip(Icons.calendar_today, game.released!.substring(0, 4));
      }
      if (game.rating != null && game.rating! > 0) {
        addChip(Icons.star, game.rating!.toStringAsFixed(1));
      }
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildSynopsis(BuildContext context) {
    String? synopsis;
    if (entity is Media) synopsis = (entity as Media).overview;
    if (entity is Book) synopsis = (entity as Book).description;
    if (entity is Game) synopsis = (entity as Game).summary;

    if (synopsis == null || synopsis.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detailSynopsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          synopsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializedInfo(BuildContext context) {
    if (entity is Media) return MediaInfoSection(media: entity as Media);
    if (entity is Book) return BookInfoSection(book: entity as Book);
    if (entity is Game) return GameInfoSection(game: entity as Game);
    return const SizedBox.shrink();
  }
}
