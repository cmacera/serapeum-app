import 'package:flutter/material.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import 'detail_section_widgets.dart';

class TvExtraSection extends StatelessWidget {
  final List<SeasonSummary> seasons;
  final List<Network> networks;
  final List<Creator> creators;

  const TvExtraSection({
    super.key,
    required this.seasons,
    required this.networks,
    required this.creators,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (creators.isNotEmpty)
          _CreatorsSection(creators: creators, l10n: l10n),
        if (networks.isNotEmpty)
          _NetworksSection(networks: networks, l10n: l10n),
        if (seasons.isNotEmpty) _SeasonsSection(seasons: seasons, l10n: l10n),
      ],
    );
  }
}

class _CreatorsSection extends StatelessWidget {
  final List<Creator> creators;
  final AppLocalizations l10n;

  const _CreatorsSection({required this.creators, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final names = creators.map((c) => c.name).join(', ');
    return InfoSection(title: l10n.detailCreators, content: names);
  }
}

class _NetworksSection extends StatelessWidget {
  final List<Network> networks;
  final AppLocalizations l10n;

  const _NetworksSection({required this.networks, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final names = networks.map((n) => n.name).join(', ');
    return InfoSection(title: l10n.detailNetworks, content: names);
  }
}

class _SeasonsSection extends StatelessWidget {
  final List<SeasonSummary> seasons;
  final AppLocalizations l10n;

  const _SeasonsSection({required this.seasons, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regularSeasons = seasons.where((s) => s.seasonNumber > 0).toList();
    if (regularSeasons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailSeasons),
          const SizedBox(height: 8),
          ...regularSeasons.map(
            (season) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Text(
                    '${season.seasonNumber}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      season.name,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.detailEpisodes(season.episodeCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
