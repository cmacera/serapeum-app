import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../../core/constants/tmdb_genres.dart';
import '../../../domain/entities/media.dart';
import '../../../domain/entities/media_detail.dart';
import '../../../presentation/providers/media_detail_provider.dart';
import 'cast_section.dart';
import 'detail_section_widgets.dart';
import 'tv_extra_section.dart';
import 'watch_providers_section.dart';

class MediaInfoSection extends ConsumerWidget {
  final Media media;

  const MediaInfoSection({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    if (media.mediaType == MediaType.movie) {
      final detailAsync = ref.watch(movieDetailProvider(media.id));
      return detailAsync.when(
        loading: () => _LoadingEnriched(l10n: l10n),
        error: (_, _) => _EnrichmentError(l10n: l10n),
        data: (detail) => _MovieDetailContent(detail: detail, l10n: l10n),
      );
    }

    if (media.mediaType == MediaType.tv) {
      final detailAsync = ref.watch(tvDetailProvider(media.id));
      return detailAsync.when(
        loading: () => _LoadingEnriched(l10n: l10n),
        error: (_, _) => _EnrichmentError(l10n: l10n),
        data: (detail) => _TvDetailContent(detail: detail, l10n: l10n),
      );
    }

    // Unknown type — fall back to genre chips from genreIds
    final genres = resolveGenreNames(media.genreIds, l10n);
    if (genres.isEmpty) return const SizedBox.shrink();
    return InfoSection(title: l10n.detailGenres, content: genres.join(', '));
  }
}

class _LoadingEnriched extends StatelessWidget {
  final AppLocalizations l10n;

  const _LoadingEnriched({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.detailLoadingEnriched,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnrichmentError extends StatelessWidget {
  final AppLocalizations l10n;

  const _EnrichmentError({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        l10n.detailEnrichmentError,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MovieDetailContent extends StatelessWidget {
  final MovieDetail detail;
  final AppLocalizations l10n;

  const _MovieDetailContent({required this.detail, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final watchRegion = _resolveWatchRegion(detail.watchProviders);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.genres.isNotEmpty)
          InfoSection(
            title: l10n.detailGenres,
            content: detail.genres.join(', '),
          ),
        if (detail.tagline != null && detail.tagline!.isNotEmpty)
          _TaglineSection(tagline: detail.tagline!, l10n: l10n),
        if (detail.cast.isNotEmpty) CastSection(cast: detail.cast),
        if (watchRegion != null) WatchProvidersSection(region: watchRegion),
      ],
    );
  }

  WatchProviderRegion? _resolveWatchRegion(
    Map<String, WatchProviderRegion> providers,
  ) {
    if (providers.isEmpty) return null;
    final countryCode = PlatformDispatcher.instance.locale.countryCode
        ?.toUpperCase();
    if (countryCode != null && providers.containsKey(countryCode)) {
      return providers[countryCode];
    }
    return providers.values.first;
  }
}

class _TvDetailContent extends StatelessWidget {
  final TvDetail detail;
  final AppLocalizations l10n;

  const _TvDetailContent({required this.detail, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final watchRegion = _resolveWatchRegion(detail.watchProviders);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.genres.isNotEmpty)
          InfoSection(
            title: l10n.detailGenres,
            content: detail.genres.join(', '),
          ),
        if (detail.tagline != null && detail.tagline!.isNotEmpty)
          _TaglineSection(tagline: detail.tagline!, l10n: l10n),
        if (detail.cast.isNotEmpty) CastSection(cast: detail.cast),
        if (watchRegion != null) WatchProvidersSection(region: watchRegion),
        if (detail.seasons.isNotEmpty ||
            detail.networks.isNotEmpty ||
            detail.creators.isNotEmpty)
          TvExtraSection(
            seasons: detail.seasons,
            networks: detail.networks,
            creators: detail.creators,
          ),
      ],
    );
  }

  WatchProviderRegion? _resolveWatchRegion(
    Map<String, WatchProviderRegion> providers,
  ) {
    if (providers.isEmpty) return null;
    final countryCode = PlatformDispatcher.instance.locale.countryCode
        ?.toUpperCase();
    if (countryCode != null && providers.containsKey(countryCode)) {
      return providers[countryCode];
    }
    return providers.values.first;
  }
}

class _TaglineSection extends StatelessWidget {
  final String tagline;
  final AppLocalizations l10n;

  const _TaglineSection({required this.tagline, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailTagline),
          const SizedBox(height: 8),
          Text(
            '"$tagline"',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
