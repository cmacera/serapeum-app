import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../core/enums/media_card_type.dart';
import '../../core/utils/tmdb_image_utils.dart';
import '../utils/remove_from_library_dialog.dart';
import '../../features/discovery/domain/entities/book.dart';
import '../../features/discovery/domain/entities/game.dart';
import '../../features/discovery/domain/entities/media.dart';
import '../../features/discovery/presentation/providers/media_detail_provider.dart';
import 'bookmark_button.dart';
import '../../features/discovery/presentation/widgets/detail_sections/book_info_section.dart';
import '../../features/discovery/presentation/widgets/detail_sections/game_info_section.dart';
import '../../features/discovery/presentation/widgets/detail_sections/media_info_section.dart';
import '../../features/library/data/local/library_item.dart';
import '../../features/library/data/providers/library_provider.dart';
import '../../features/library/presentation/widgets/library_user_sections.dart';

class MediaDetailModal extends ConsumerWidget {
  final Object entity;
  final ScrollController? scrollController;

  const MediaDetailModal({
    super.key,
    required this.entity,
    this.scrollController,
  }) : assert(entity is Media || entity is Book || entity is Game);

  (String externalId, String mediaType) get _entityKey => switch (entity) {
    Media m => (m.id.toString(), m.mediaType == MediaType.tv ? 'tv' : 'movie'),
    Book b => (b.id, 'book'),
    Game g => (g.id.toString(), 'game'),
    _ => throw ArgumentError('Unknown entity type: $entity'),
  };

  MediaCardType get _mediaCardType => switch (entity) {
    Media m when m.mediaType == MediaType.tv => MediaCardType.tv,
    Media _ => MediaCardType.movie,
    Book _ => MediaCardType.book,
    Game _ => MediaCardType.game,
    _ => MediaCardType.movie,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final (externalId, mediaType) = _entityKey;
    final libraryItems = ref.watch(libraryProvider);
    final savedItem = libraryItems
        .where((i) => i.externalId == externalId && i.mediaType == mediaType)
        .firstOrNull;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      child: Material(
        color: theme.colorScheme.surface,
        child: CustomScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            _buildImmersiveHeader(context, ref, savedItem),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (savedItem != null) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: UserRatingSection(
                                    libraryItem: savedItem,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: UserConsumedSection(
                                    libraryItem: savedItem,
                                    mediaType: _mediaCardType,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          UserReviewSection(libraryItem: savedItem),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                    ],
                    _MetaStatsRow(entity: entity),
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
      final backdrop = m.backdropPath?.trim();
      if (backdrop != null && backdrop.isNotEmpty) {
        return tmdbBackdropUrl(backdrop);
      }
      final poster = m.posterPath?.trim();
      if (poster != null && poster.isNotEmpty) {
        return tmdbPosterUrl(poster);
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

  Widget _buildImmersiveHeader(
    BuildContext context,
    WidgetRef ref,
    LibraryItem? savedItem,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = _getTitle(l10n);
    final backdropUrl = _getBackdropUrl();
    final topInset = MediaQuery.paddingOf(context).top;

    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // Background Image — fixed height prevents portrait covers from
          // rendering thousands of pixels tall on wide macOS windows.
          if (backdropUrl != null)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Image.network(
                backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              height: 220,
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
            bottom: 4,
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
            top: topInset + 10,
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
            top: topInset + 10,
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

          // Bookmark button
          Positioned(
            top: topInset + 10,
            right: 12,
            child: BookmarkButton(
              isSaved: savedItem != null,
              onTap: () => _handleBookmarkTap(context, ref, savedItem),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBookmarkTap(
    BuildContext context,
    WidgetRef ref,
    LibraryItem? savedItem,
  ) {
    if (savedItem != null) {
      _doRemove(context, ref, savedItem);
    } else {
      _doSave(ref);
    }
  }

  void _doSave(WidgetRef ref) {
    final (externalId, mediaType) = _entityKey;
    switch (entity) {
      case Media m:
        ref
            .read(libraryProvider.notifier)
            .addItem(
              externalId: externalId,
              mediaType: mediaType,
              title: m.title ?? m.name ?? '',
              subtitle: _buildSubtitle(
                _extractYear(m.releaseDate),
                _formatRating(m.voteAverage),
              ),
              imageUrl: tmdbPosterUrl(m.posterPath),
              backdropImageUrl: tmdbBackdropUrl(m.backdropPath),
              rating: m.voteAverage?.toDouble(),
              itemJson: jsonEncode(m.toJson()),
            );
      case Book b:
        final imageUrl =
            b.imageLinks?['thumbnail'] ?? b.imageLinks?['smallThumbnail'];
        ref
            .read(libraryProvider.notifier)
            .addItem(
              externalId: externalId,
              mediaType: mediaType,
              title: b.title,
              subtitle: _buildSubtitle(_extractYear(b.publishedDate), null),
              imageUrl: imageUrl,
              backdropImageUrl: imageUrl,
              rating: b.averageRating?.toDouble(),
              itemJson: jsonEncode(b.toJson()),
            );
      case Game g:
        ref
            .read(libraryProvider.notifier)
            .addItem(
              externalId: externalId,
              mediaType: mediaType,
              title: g.name,
              subtitle: _buildSubtitle(
                _extractYear(g.released),
                _formatRating(g.rating ?? g.aggregatedRating),
              ),
              imageUrl: g.coverUrl,
              backdropImageUrl: g.screenshots?.firstOrNull,
              rating: (g.rating ?? g.aggregatedRating)?.toDouble(),
              itemJson: jsonEncode(g.toJson()),
            );
    }
  }

  void _doRemove(BuildContext context, WidgetRef ref, LibraryItem savedItem) {
    if (savedItem.hasUserData) {
      showRemoveFromLibraryDialog(context, savedItem.title, () {
        ref
            .read(libraryProvider.notifier)
            .removeItem(savedItem.externalId, savedItem.mediaType);
      });
    } else {
      ref
          .read(libraryProvider.notifier)
          .removeItem(savedItem.externalId, savedItem.mediaType);
    }
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

  // --- Private helpers for building LibraryItem data ---

  String? _extractYear(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    final match = RegExp(r'\d{4}').firstMatch(dateStr);
    return match?.group(0);
  }

  String? _formatRating(num? rating) {
    if (rating == null || rating == 0) return null;
    return '★ ${rating.toStringAsFixed(1)}';
  }

  String? _buildSubtitle(String? year, String? rating) {
    final parts = [year, rating].whereType<String>().toList();
    if (parts.isEmpty) return null;
    return parts.join('  ·  ');
  }
}

class _MetaStatsRow extends ConsumerWidget {
  final Object entity;

  const _MetaStatsRow({required this.entity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    Widget chip(IconData icon, String text) => Container(
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
    );

    if (entity is Media) {
      final media = entity as Media;

      // Basic chips — always available immediately
      if (media.releaseDate != null && media.releaseDate!.length >= 4) {
        chips.add(
          chip(Icons.calendar_today, media.releaseDate!.substring(0, 4)),
        );
      }
      if (media.voteAverage != null && media.voteAverage! > 0) {
        chips.add(chip(Icons.star, media.voteAverage!.toStringAsFixed(1)));
      }
      final lang = media.originalLanguage?.trim();
      if (lang != null && lang.isNotEmpty) {
        chips.add(chip(Icons.language, lang.toUpperCase()));
      }

      void addCertificationChip(String? certification) {
        if (certification != null && certification.trim().isNotEmpty) {
          chips.add(chip(Icons.shield_outlined, certification.trim()));
        }
      }

      // Enriched chips — added once detail loads
      if (media.mediaType == MediaType.movie) {
        ref.watch(movieDetailProvider(media.id)).whenData((d) {
          addCertificationChip(d.certification);
          if (d.runtime != null && d.runtime! > 0) {
            final h = d.runtime! ~/ 60;
            final m = d.runtime! % 60;
            chips.add(chip(Icons.schedule, h > 0 ? '${h}h ${m}m' : '${m}m'));
          }
          if (d.budget != null && d.budget! > 0) {
            chips.add(
              chip(
                Icons.attach_money,
                '\$${(d.budget! / 1e6).toStringAsFixed(0)}M',
              ),
            );
          }
          if (d.revenue != null && d.revenue! > 0) {
            chips.add(
              chip(
                Icons.trending_up,
                '\$${(d.revenue! / 1e6).toStringAsFixed(0)}M',
              ),
            );
          }
        });
      } else if (media.mediaType == MediaType.tv) {
        ref.watch(tvDetailProvider(media.id)).whenData((d) {
          addCertificationChip(d.certification);
          if (d.episodeRunTime.isNotEmpty) {
            chips.add(chip(Icons.schedule, '${d.episodeRunTime.first}m'));
          }
        });
      }
    } else if (entity is Book) {
      final book = entity as Book;
      final l10n = AppLocalizations.of(context)!;
      if (book.publishedDate != null && book.publishedDate!.length >= 4) {
        chips.add(
          chip(Icons.calendar_today, book.publishedDate!.substring(0, 4)),
        );
      }
      if (book.pageCount != null) {
        chips.add(chip(Icons.auto_stories, '${book.pageCount} p.'));
      }
      if (book.averageRating != null && book.averageRating! > 0) {
        chips.add(chip(Icons.star, book.averageRating!.toStringAsFixed(1)));
      }
      final maturity = book.maturityRating?.trim() ?? '';
      if (maturity.isNotEmpty) {
        chips.add(
          chip(
            Icons.shield_outlined,
            maturity == Book.maturityNotMature
                ? l10n.maturityRatingForAll
                : l10n.maturityRatingMature,
          ),
        );
      }
    } else if (entity is Game) {
      final game = entity as Game;
      if (game.released != null && game.released!.length >= 4) {
        chips.add(chip(Icons.calendar_today, game.released!.substring(0, 4)));
      }
      if (game.rating != null && game.rating! > 0) {
        chips.add(chip(Icons.star, game.rating!.toStringAsFixed(1)));
      }
      final countryCode = PlatformDispatcher.instance.locale.countryCode;
      final regionalRating = _regionalAgeRating(game.ageRatings, countryCode);
      if (regionalRating != null) {
        chips.add(
          chip(
            Icons.shield_outlined,
            '${regionalRating.organization} ${regionalRating.rating}',
          ),
        );
      }
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  static const _orgEsrb = 'ESRB';
  static const _orgCero = 'CERO';
  static const _orgUsk = 'USK';
  static const _orgGrac = 'GRAC';
  static const _orgClassInd = 'ClassInd';
  static const _orgAcb = 'ACB';
  static const _orgPegi = 'PEGI';

  static const _countryToOrg = <String, String>{
    'US': _orgEsrb,
    'CA': _orgEsrb,
    'JP': _orgCero,
    'DE': _orgUsk,
    'KR': _orgGrac,
    'BR': _orgClassInd,
    'AU': _orgAcb,
    'NZ': _orgAcb,
  };

  static String _preferredOrg(String? countryCode) =>
      _countryToOrg[countryCode?.toUpperCase()] ?? _orgPegi;

  static AgeRating? _regionalAgeRating(
    List<AgeRating>? ratings,
    String? countryCode,
  ) {
    if (ratings == null || ratings.isEmpty) return null;
    final preferred = _preferredOrg(countryCode);
    return ratings
        .where((ar) => ar.organization.toUpperCase() == preferred.toUpperCase())
        .firstOrNull;
  }
}
