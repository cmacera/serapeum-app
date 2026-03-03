import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../domain/entities/game.dart';
import 'detail_section_widgets.dart';

class GameInfoSection extends StatelessWidget {
  final Game game;

  const GameInfoSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (game.screenshots != null && game.screenshots!.isNotEmpty) ...[
          SectionTitle(title: l10n.detailScreenshots),
          const SizedBox(height: 8),
          _buildScreenshotStrip(game.screenshots!),
          const SizedBox(height: 16),
        ],
        if (game.platforms != null && game.platforms!.isNotEmpty)
          InfoSection(
            title: l10n.detailPlatforms,
            content: game.platforms!.join(', '),
          ),
        if (game.genres != null && game.genres!.isNotEmpty)
          InfoSection(
            title: l10n.detailGenres,
            content: game.genres!.join(', '),
          ),
        if (game.themes != null && game.themes!.isNotEmpty)
          InfoSection(
            title: l10n.detailThemes,
            content: game.themes!.join(', '),
          ),
        if (game.gameModes != null && game.gameModes!.isNotEmpty)
          InfoSection(
            title: l10n.detailGameModes,
            content: game.gameModes!.join(', '),
          ),
        if (game.developers != null && game.developers!.isNotEmpty)
          InfoSection(
            title: l10n.detailDevelopers,
            content: game.developers!.join(', '),
          ),
        if (game.ageRatings != null && game.ageRatings!.isNotEmpty) ...[
          SectionTitle(title: l10n.detailAgeRatings),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: game.ageRatings!
                .map((ar) => AgeRatingChip(label: _formatAgeRating(ar)))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (game.similarGames != null && game.similarGames!.isNotEmpty)
          InfoSection(
            title: l10n.detailSimilarGames,
            content: game.similarGames!.map((g) => g.name).join(', '),
          ),
      ],
    );
  }

  Widget _buildScreenshotStrip(List<String> urls) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: urls[index],
            height: 140,
            width: 220,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 220,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 220,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatAgeRating(AgeRating ar) {
    const esrb = {
      6: 'RP',
      7: 'EC',
      8: 'E',
      9: 'E10+',
      10: 'T',
      11: 'M',
      12: 'AO',
    };
    const pegi = {1: '3', 2: '7', 3: '12', 4: '16', 5: '18'};
    final cat = ar.category == 1
        ? 'ESRB'
        : ar.category == 2
        ? 'PEGI'
        : '#${ar.category}';
    final rating =
        (ar.category == 1 ? esrb : pegi)[ar.rating] ?? '${ar.rating}';
    return '$cat $rating';
  }
}
