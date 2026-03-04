// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SERAPEUM';

  @override
  String get myLibraryTitle => 'My Library';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get controlCenterTitle => 'Control Center';

  @override
  String get askOracleHint => 'Ask the Oracle anything...';

  @override
  String get askOracleTooltip => 'Ask Oracle';

  @override
  String get discoveryHistoryTitle => 'History';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get newConversation => 'New Conversation';

  @override
  String get noHistory => 'No history yet';

  @override
  String get clearHistoryConfirmation =>
      'Are you sure you want to clear all search history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get noResponseFromOracle => 'No response from the Oracle.';

  @override
  String get resultIntro =>
      'Here is what I found specifically for your request:';

  @override
  String oracleErrorTemplate(String error, String details) {
    return 'The Oracle encountered an error: $error$details';
  }

  @override
  String get noMatches => 'No matching items found in the catalogs.';

  @override
  String queryError(String error) {
    return 'Error querying the Oracle: $error';
  }

  @override
  String get unknownMedia => 'Unknown Media';

  @override
  String bookSubtitle(String date) {
    return 'BOOK · $date';
  }

  @override
  String get unknownYear => 'Unknown Year';

  @override
  String get gameSubtitle => 'GAME';

  @override
  String get queryFailed =>
      'I\'m sorry, I couldn\'t process your request right now. Please try again later.';

  @override
  String get outOfScopeTitle => 'Out of Scope';

  @override
  String get errorTitle => 'Oracle Error';

  @override
  String get ok => 'OK';

  @override
  String get networkError =>
      'Network error. Please check your internet connection.';

  @override
  String get timeoutError =>
      'The request timed out. The Oracle is busy or the connection is slow.';

  @override
  String serverError(int code) {
    return 'The server returned an error ($code).';
  }

  @override
  String get consultingOracle => 'Consulting the Oracle...';

  @override
  String elapsedSecondsLabel(int seconds) {
    return '${seconds}s elapsed';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterMedia => 'Media';

  @override
  String get filterBooks => 'Books';

  @override
  String get filterGames => 'Games';

  @override
  String get mediaTypeMovie => 'MOVIE';

  @override
  String get mediaTypeTv => 'TV SERIES';

  @override
  String get mediaTypeUnknown => 'MEDIA';

  @override
  String get detailSynopsis => 'Synopsis';

  @override
  String get detailPublishingInfo => 'Publishing Info';

  @override
  String get detailAuthors => 'Authors';

  @override
  String get detailPublisher => 'Publisher';

  @override
  String get detailPlatforms => 'Platforms';

  @override
  String get detailGenres => 'Genres';

  @override
  String get detailDevelopers => 'Developers';

  @override
  String get detailDefaultTitle => 'Details';

  @override
  String get unknownPublisher => 'Unknown Publisher';

  @override
  String get unknownAuthors => 'Unknown';

  @override
  String get genreAction => 'Action';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreAnimation => 'Animation';

  @override
  String get genreComedy => 'Comedy';

  @override
  String get genreCrime => 'Crime';

  @override
  String get genreDocumentary => 'Documentary';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreFamily => 'Family';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreHistory => 'History';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genreMusic => 'Music';

  @override
  String get genreMystery => 'Mystery';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreSciFi => 'Science Fiction';

  @override
  String get genreTvMovie => 'TV Movie';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreWar => 'War';

  @override
  String get genreWestern => 'Western';

  @override
  String get genreActionAdventure => 'Action & Adventure';

  @override
  String get genreKids => 'Kids';

  @override
  String get genreNews => 'News';

  @override
  String get genreReality => 'Reality';

  @override
  String get genreSciFiFantasy => 'Sci-Fi & Fantasy';

  @override
  String get genreSoap => 'Soap';

  @override
  String get genreTalk => 'Talk';

  @override
  String get genreWarPolitics => 'War & Politics';

  @override
  String get detailOriginalLanguage => 'Language';

  @override
  String get detailThemes => 'Themes';

  @override
  String get detailGameModes => 'Game Modes';

  @override
  String get detailAgeRatings => 'Age Ratings';

  @override
  String get detailSimilarGames => 'Similar Games';

  @override
  String get detailAverageRating => 'User Rating';

  @override
  String get detailMaturityRating => 'Maturity Rating';

  @override
  String get maturityRatingForAll => 'For all audiences';

  @override
  String get maturityRatingMature => 'Mature content';

  @override
  String get detailScreenshots => 'Screenshots';

  @override
  String get detailTrailers => 'Trailers';

  @override
  String get playTrailer => 'Play trailer';

  @override
  String get detailIsbn => 'ISBN';

  @override
  String get detailCast => 'Cast';

  @override
  String get detailWhereToWatch => 'Where to Watch';

  @override
  String get detailWatchStream => 'Streaming';

  @override
  String get detailWatchRent => 'Rent';

  @override
  String get detailWatchBuy => 'Buy';

  @override
  String get detailSeasons => 'Seasons';

  @override
  String get detailNetworks => 'Networks';

  @override
  String get detailCreators => 'Creators';

  @override
  String get detailRuntime => 'Runtime';

  @override
  String get detailTagline => 'Tagline';

  @override
  String detailTaglineQuoted(String tagline) {
    return '\"$tagline\"';
  }

  @override
  String get detailBudget => 'Budget';

  @override
  String get detailRevenue => 'Revenue';

  @override
  String get detailLoadingEnriched => 'Loading details…';

  @override
  String get detailEnrichmentError => 'Could not load additional details';

  @override
  String detailEpisodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }
}
