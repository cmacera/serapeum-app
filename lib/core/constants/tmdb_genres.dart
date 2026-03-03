import '../../l10n/app_localizations.dart';

/// Maps TMDB genre IDs to their localized display name via [AppLocalizations].
/// Returns an empty list when [ids] is null or empty, or when none of the IDs
/// are recognized.
List<String> resolveGenreNames(List<int>? ids, AppLocalizations l10n) {
  if (ids == null || ids.isEmpty) return const [];
  return ids.map((id) => _resolve(id, l10n)).whereType<String>().toList();
}

String? _resolve(int id, AppLocalizations l10n) => switch (id) {
  28 => l10n.genreAction,
  12 => l10n.genreAdventure,
  16 => l10n.genreAnimation,
  35 => l10n.genreComedy,
  80 => l10n.genreCrime,
  99 => l10n.genreDocumentary,
  18 => l10n.genreDrama,
  10751 => l10n.genreFamily,
  14 => l10n.genreFantasy,
  36 => l10n.genreHistory,
  27 => l10n.genreHorror,
  10402 => l10n.genreMusic,
  9648 => l10n.genreMystery,
  10749 => l10n.genreRomance,
  878 => l10n.genreSciFi,
  10770 => l10n.genreTvMovie,
  53 => l10n.genreThriller,
  10752 => l10n.genreWar,
  37 => l10n.genreWestern,
  // TV-specific
  10759 => l10n.genreActionAdventure,
  10762 => l10n.genreKids,
  10763 => l10n.genreNews,
  10764 => l10n.genreReality,
  10765 => l10n.genreSciFiFantasy,
  10766 => l10n.genreSoap,
  10767 => l10n.genreTalk,
  10768 => l10n.genreWarPolitics,
  _ => null,
};
