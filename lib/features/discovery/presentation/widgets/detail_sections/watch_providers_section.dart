import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'detail_section_widgets.dart';

class WatchProvidersSection extends StatelessWidget {
  final WatchProviderRegion region;

  const WatchProvidersSection({super.key, required this.region});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final flatrate = region.flatrate ?? [];
    final rent = region.rent ?? [];
    final buy = region.buy ?? [];

    if (flatrate.isEmpty && rent.isEmpty && buy.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailWhereToWatch),
          if (flatrate.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ProviderSubsection(
              label: l10n.detailWatchStream,
              providers: flatrate,
              link: region.link,
            ),
          ],
          if (rent.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ProviderSubsection(
              label: l10n.detailWatchRent,
              providers: rent,
              link: region.link,
            ),
          ],
          if (buy.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ProviderSubsection(
              label: l10n.detailWatchBuy,
              providers: buy,
              link: region.link,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProviderSubsection extends StatelessWidget {
  final String label;
  final List<WatchProvider> providers;
  final String link;

  const _ProviderSubsection({
    required this.label,
    required this.providers,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providers
              .map((p) => _ProviderLogo(provider: p, link: link))
              .toList(),
        ),
      ],
    );
  }
}

class _ProviderLogo extends StatelessWidget {
  final WatchProvider provider;
  final String link;

  const _ProviderLogo({required this.provider, required this.link});

  @override
  Widget build(BuildContext context) {
    final logoUrl =
        '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW45}${provider.logoPath}';
    return Tooltip(
      message: provider.providerName,
      child: InkWell(
        onTap: () async {
          final uri = Uri.tryParse(link);
          if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
            debugPrint('WatchProvidersSection: invalid watch link "$link"');
            return;
          }
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            debugPrint('WatchProvidersSection: could not launch "$link"');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
