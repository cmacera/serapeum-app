import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../../core/constants/tmdb_genres.dart';
import '../../../domain/entities/media.dart';
import 'detail_section_widgets.dart';

class MediaInfoSection extends StatelessWidget {
  final Media media;

  const MediaInfoSection({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final genres = resolveGenreNames(media.genreIds, l10n);
    if (genres.isEmpty) return const SizedBox.shrink();
    return InfoSection(title: l10n.detailGenres, content: genres.join(', '));
  }
}
