import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:serapeum_app/core/constants/api_constants.dart';
import 'package:serapeum_app/features/discovery/domain/entities/media_detail.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import 'detail_section_widgets.dart';

// Horizontal padding applied by the parent modal (EdgeInsets.all(24)).
// Used to restore content alignment inside the full-bleed list.
const double _parentHorizontalPadding = 24.0;

class CastSection extends StatelessWidget {
  final List<CastMember> cast;

  const CastSection({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: l10n.detailCast),
          const SizedBox(height: 8.0),
          // SizedBox fixes the height for Column layout.
          // OverflowBox then lets the list exceed the 24px horizontal padding,
          // reaching screen edges. Alignment.center overflows equally on both sides.
          SizedBox(
            height: 88,
            child: OverflowBox(
              maxWidth: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 88,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _parentHorizontalPadding,
                  ),
                  itemCount: cast.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return _CastMemberCard(member: cast[index], theme: theme);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CastMemberCard extends StatelessWidget {
  final CastMember member;
  final ThemeData theme;

  const _CastMemberCard({required this.member, required this.theme});

  @override
  Widget build(BuildContext context) {
    final path = member.profilePath?.trim();
    final profileUrl = (path != null && path.isNotEmpty)
        ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW185}$path'
        : null;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _ProfilePhoto(profileUrl: profileUrl, theme: theme),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    member.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    member.character,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
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

class _ProfilePhoto extends StatelessWidget {
  final String? profileUrl;
  final ThemeData theme;

  const _ProfilePhoto({required this.profileUrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (profileUrl != null) {
      return CachedNetworkImage(
        imageUrl: profileUrl!,
        width: 64,
        height: 88,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => _Placeholder(theme: theme),
      );
    }
    return _Placeholder(theme: theme);
  }
}

class _Placeholder extends StatelessWidget {
  final ThemeData theme;

  const _Placeholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 88,
      child: Icon(Icons.person, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
