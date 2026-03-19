import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../domain/entities/game.dart';
import 'package:serapeum_app/shared/widgets/fullscreen_image_viewer.dart';
import 'detail_section_widgets.dart';

const _kStripHeight = 140.0;
const _kThumbnailWidth = 220.0;

class GameInfoSection extends StatelessWidget {
  final Game game;

  const GameInfoSection({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._buildScreenshotSection(context, l10n),
        ..._buildTrailersSection(),
        _filteredInfoSection(game.platforms, l10n.detailPlatforms),
        _filteredInfoSection(game.genres, l10n.detailGenres),
        _filteredInfoSection(game.themes, l10n.detailThemes),
        _filteredInfoSection(game.gameModes, l10n.detailGameModes),
        _filteredInfoSection(game.developers, l10n.detailDevelopers),
        _filteredInfoSection(
          game.similarGames?.map((g) => g.name).toList(),
          l10n.detailSimilarGames,
        ),
      ].whereType<Widget>().toList(),
    );
  }

  static final _youtubeIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  static String? _extractYoutubeId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (_youtubeIdPattern.hasMatch(trimmed)) return trimmed;
    try {
      final uri = Uri.parse(trimmed);
      String? candidate;
      if (uri.host.contains('youtu.be')) {
        candidate = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com')) {
        candidate = uri.queryParameters['v'];
      }
      if (candidate != null && _youtubeIdPattern.hasMatch(candidate)) {
        return candidate;
      }
    } catch (_) {}
    return null;
  }

  /// Returns the trailers section widgets after validating and extracting
  /// YouTube video IDs, or an empty list if no valid entries remain.
  List<Widget> _buildTrailersSection() {
    if (game.videos == null) return const [];
    final ids = game.videos!
        .map(_extractYoutubeId)
        .whereType<String>()
        .toList();
    if (ids.isEmpty) return const [];
    return [TrailersSection(youtubeIds: ids)];
  }

  List<Widget> _buildScreenshotSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (game.screenshots == null) return const [];
    final screenshots = game.screenshots!
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    if (screenshots.isEmpty) return const [];
    return [
      SectionTitle(title: l10n.detailScreenshots),
      const SizedBox(height: 8),
      _buildScreenshotStrip(context, screenshots),
      const SizedBox(height: 16),
    ];
  }

  /// Returns an [InfoSection] after trimming and filtering [items],
  /// or `null` if no valid entries remain.
  static Widget? _filteredInfoSection(List<String>? items, String title) {
    if (items == null || items.isEmpty) return null;
    final cleaned = items
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) return null;
    return InfoSection(title: title, content: cleaned.join(', '));
  }

  Widget _buildScreenshotStrip(BuildContext context, List<String> urls) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: _kStripHeight,
      child: OverflowBox(
        maxWidth: screenWidth,
        alignment: Alignment.center,
        child: SizedBox(
          width: screenWidth,
          height: _kStripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: kDetailModalHorizontalPadding,
            ),
            itemCount: urls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final url = urls[index];
              final l10n = AppLocalizations.of(context)!;
              return Semantics(
                button: true,
                label: l10n.viewScreenshot,
                child: GestureDetector(
                  onTap: () => FullscreenImageViewer.show(
                    context,
                    urls: urls,
                    initialIndex: index,
                  ),
                  child: Hero(
                    tag: FullscreenImageViewer.heroTag(url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        height: _kStripHeight,
                        width: _kThumbnailWidth,
                        fit: BoxFit.cover,
                        placeholder: (context, _) => Container(
                          width: _kThumbnailWidth,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, _, _) => Container(
                          width: _kThumbnailWidth,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
