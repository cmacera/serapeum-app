import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'SERAPEUM'**
  String get appName;

  /// Title for the My Library screen (bottom nav tab)
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibraryTitle;

  /// Title for the Discover / Oracle screen (bottom nav tab)
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// Title for the Control Center / Settings screen (bottom nav tab)
  ///
  /// In en, this message translates to:
  /// **'Control Center'**
  String get controlCenterTitle;

  /// Placeholder hint text inside the Oracle search input field
  ///
  /// In en, this message translates to:
  /// **'Ask the Oracle anything...'**
  String get askOracleHint;

  /// Tooltip for the Oracle send button
  ///
  /// In en, this message translates to:
  /// **'Ask Oracle'**
  String get askOracleTooltip;

  /// Title for the discovery history screen
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get discoveryHistoryTitle;

  /// Button text to clear search history
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// Tooltip for starting a new conversation
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// Text shown when history is empty
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistory;

  /// No description provided for @clearHistoryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all search history?'**
  String get clearHistoryConfirmation;

  /// Label for the delete button on an individual history entry
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteHistoryItem;

  /// Confirmation prompt shown before deleting a single history entry
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this history entry?'**
  String get deleteHistoryItemConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noResponseFromOracle.
  ///
  /// In en, this message translates to:
  /// **'No response from the Oracle.'**
  String get noResponseFromOracle;

  /// No description provided for @resultIntro.
  ///
  /// In en, this message translates to:
  /// **'Here is what I found specifically for your request:'**
  String get resultIntro;

  /// No description provided for @oracleErrorTemplate.
  ///
  /// In en, this message translates to:
  /// **'The Oracle encountered an error: {error}{details}'**
  String oracleErrorTemplate(String error, String details);

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching items found in the catalogs.'**
  String get noMatches;

  /// No description provided for @queryError.
  ///
  /// In en, this message translates to:
  /// **'Error querying the Oracle: {error}'**
  String queryError(String error);

  /// No description provided for @unknownMedia.
  ///
  /// In en, this message translates to:
  /// **'Unknown Media'**
  String get unknownMedia;

  /// No description provided for @bookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'BOOK · {date}'**
  String bookSubtitle(String date);

  /// No description provided for @unknownYear.
  ///
  /// In en, this message translates to:
  /// **'Unknown Year'**
  String get unknownYear;

  /// No description provided for @gameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GAME'**
  String get gameSubtitle;

  /// No description provided for @queryFailed.
  ///
  /// In en, this message translates to:
  /// **'I\'m sorry, I couldn\'t process your request right now. Please try again later.'**
  String get queryFailed;

  /// No description provided for @outOfScopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of Scope'**
  String get outOfScopeTitle;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Oracle Error'**
  String get errorTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. The Oracle is busy or the connection is slow.'**
  String get timeoutError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'The server returned an error ({code}).'**
  String serverError(int code);

  /// Loading message shown while the Oracle (AI) is processing the request
  ///
  /// In en, this message translates to:
  /// **'Consulting the Oracle...'**
  String get consultingOracle;

  /// Label for the debug timer showing elapsed seconds
  ///
  /// In en, this message translates to:
  /// **'{seconds}s elapsed'**
  String elapsedSecondsLabel(int seconds);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get filterMedia;

  /// No description provided for @filterBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get filterBooks;

  /// No description provided for @filterGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get filterGames;

  /// No description provided for @mediaTypeMovie.
  ///
  /// In en, this message translates to:
  /// **'MOVIE'**
  String get mediaTypeMovie;

  /// No description provided for @mediaTypeTv.
  ///
  /// In en, this message translates to:
  /// **'TV SERIES'**
  String get mediaTypeTv;

  /// No description provided for @mediaTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'MEDIA'**
  String get mediaTypeUnknown;

  /// No description provided for @detailSynopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get detailSynopsis;

  /// No description provided for @detailPublishingInfo.
  ///
  /// In en, this message translates to:
  /// **'Publishing Info'**
  String get detailPublishingInfo;

  /// No description provided for @detailAuthors.
  ///
  /// In en, this message translates to:
  /// **'Authors'**
  String get detailAuthors;

  /// No description provided for @detailPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get detailPublisher;

  /// No description provided for @detailPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Platforms'**
  String get detailPlatforms;

  /// No description provided for @detailGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get detailGenres;

  /// No description provided for @detailDevelopers.
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get detailDevelopers;

  /// No description provided for @detailDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailDefaultTitle;

  /// No description provided for @unknownPublisher.
  ///
  /// In en, this message translates to:
  /// **'Unknown Publisher'**
  String get unknownPublisher;

  /// No description provided for @unknownAuthors.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownAuthors;

  /// No description provided for @genreAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get genreAction;

  /// No description provided for @genreAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get genreAdventure;

  /// No description provided for @genreAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get genreAnimation;

  /// No description provided for @genreComedy.
  ///
  /// In en, this message translates to:
  /// **'Comedy'**
  String get genreComedy;

  /// No description provided for @genreCrime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get genreCrime;

  /// No description provided for @genreDocumentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get genreDocumentary;

  /// No description provided for @genreDrama.
  ///
  /// In en, this message translates to:
  /// **'Drama'**
  String get genreDrama;

  /// No description provided for @genreFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get genreFamily;

  /// No description provided for @genreFantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get genreFantasy;

  /// No description provided for @genreHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get genreHistory;

  /// No description provided for @genreHorror.
  ///
  /// In en, this message translates to:
  /// **'Horror'**
  String get genreHorror;

  /// No description provided for @genreMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get genreMusic;

  /// No description provided for @genreMystery.
  ///
  /// In en, this message translates to:
  /// **'Mystery'**
  String get genreMystery;

  /// No description provided for @genreRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreSciFi.
  ///
  /// In en, this message translates to:
  /// **'Science Fiction'**
  String get genreSciFi;

  /// No description provided for @genreTvMovie.
  ///
  /// In en, this message translates to:
  /// **'TV Movie'**
  String get genreTvMovie;

  /// No description provided for @genreThriller.
  ///
  /// In en, this message translates to:
  /// **'Thriller'**
  String get genreThriller;

  /// No description provided for @genreWar.
  ///
  /// In en, this message translates to:
  /// **'War'**
  String get genreWar;

  /// No description provided for @genreWestern.
  ///
  /// In en, this message translates to:
  /// **'Western'**
  String get genreWestern;

  /// No description provided for @genreActionAdventure.
  ///
  /// In en, this message translates to:
  /// **'Action & Adventure'**
  String get genreActionAdventure;

  /// No description provided for @genreKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get genreKids;

  /// No description provided for @genreNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get genreNews;

  /// No description provided for @genreReality.
  ///
  /// In en, this message translates to:
  /// **'Reality'**
  String get genreReality;

  /// No description provided for @genreSciFiFantasy.
  ///
  /// In en, this message translates to:
  /// **'Sci-Fi & Fantasy'**
  String get genreSciFiFantasy;

  /// No description provided for @genreSoap.
  ///
  /// In en, this message translates to:
  /// **'Soap'**
  String get genreSoap;

  /// No description provided for @genreTalk.
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get genreTalk;

  /// No description provided for @genreWarPolitics.
  ///
  /// In en, this message translates to:
  /// **'War & Politics'**
  String get genreWarPolitics;

  /// No description provided for @detailOriginalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get detailOriginalLanguage;

  /// No description provided for @detailThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get detailThemes;

  /// No description provided for @detailGameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get detailGameModes;

  /// No description provided for @detailAgeRatings.
  ///
  /// In en, this message translates to:
  /// **'Age Ratings'**
  String get detailAgeRatings;

  /// No description provided for @detailSimilarGames.
  ///
  /// In en, this message translates to:
  /// **'Similar Games'**
  String get detailSimilarGames;

  /// No description provided for @detailAverageRating.
  ///
  /// In en, this message translates to:
  /// **'User Rating'**
  String get detailAverageRating;

  /// No description provided for @detailMaturityRating.
  ///
  /// In en, this message translates to:
  /// **'Maturity Rating'**
  String get detailMaturityRating;

  /// No description provided for @maturityRatingForAll.
  ///
  /// In en, this message translates to:
  /// **'For all audiences'**
  String get maturityRatingForAll;

  /// No description provided for @maturityRatingMature.
  ///
  /// In en, this message translates to:
  /// **'Mature content'**
  String get maturityRatingMature;

  /// No description provided for @detailScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get detailScreenshots;

  /// No description provided for @detailTrailers.
  ///
  /// In en, this message translates to:
  /// **'Trailers'**
  String get detailTrailers;

  /// No description provided for @playTrailer.
  ///
  /// In en, this message translates to:
  /// **'Play trailer'**
  String get playTrailer;

  /// No description provided for @viewScreenshot.
  ///
  /// In en, this message translates to:
  /// **'View screenshot'**
  String get viewScreenshot;

  /// No description provided for @detailIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get detailIsbn;

  /// No description provided for @detailCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get detailCast;

  /// No description provided for @detailWhereToWatch.
  ///
  /// In en, this message translates to:
  /// **'Where to Watch'**
  String get detailWhereToWatch;

  /// No description provided for @detailWatchStream.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get detailWatchStream;

  /// No description provided for @detailWatchRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get detailWatchRent;

  /// No description provided for @detailWatchBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get detailWatchBuy;

  /// No description provided for @detailSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get detailSeasons;

  /// No description provided for @detailNetworks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get detailNetworks;

  /// No description provided for @detailCreators.
  ///
  /// In en, this message translates to:
  /// **'Creators'**
  String get detailCreators;

  /// No description provided for @detailRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get detailRuntime;

  /// No description provided for @detailTagline.
  ///
  /// In en, this message translates to:
  /// **'Tagline'**
  String get detailTagline;

  /// Tagline text wrapped in locale-appropriate quotation marks
  ///
  /// In en, this message translates to:
  /// **'\"{tagline}\"'**
  String detailTaglineQuoted(String tagline);

  /// No description provided for @detailBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get detailBudget;

  /// No description provided for @detailRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get detailRevenue;

  /// No description provided for @detailLoadingEnriched.
  ///
  /// In en, this message translates to:
  /// **'Loading details…'**
  String get detailLoadingEnriched;

  /// No description provided for @detailEnrichmentError.
  ///
  /// In en, this message translates to:
  /// **'Could not load additional details'**
  String get detailEnrichmentError;

  /// No description provided for @detailEpisodes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String detailEpisodes(int count);

  /// No description provided for @saveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to Library'**
  String get saveToLibrary;

  /// No description provided for @removeFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Remove from Library'**
  String get removeFromLibrary;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Library is empty.\nSave items from the Oracle to get started.'**
  String get libraryEmpty;

  /// No description provided for @sortOptions.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortOptions;

  /// No description provided for @sortByDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortByDateDesc;

  /// No description provided for @sortByDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortByDateAsc;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'Title (A–Z)'**
  String get sortByTitle;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get sortByRating;

  /// No description provided for @sortByType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get sortByType;

  /// Placeholder hint text inside the library search input field
  ///
  /// In en, this message translates to:
  /// **'Search library...'**
  String get searchLibraryHint;

  /// Tooltip for the library search icon button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchLibraryTooltip;

  /// Message shown when library search returns no results
  ///
  /// In en, this message translates to:
  /// **'No items match your search.'**
  String get libraryNoSearchResults;

  /// Tooltip for close/dismiss buttons
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Generic save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label for the user's personal rating section in the library detail view
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get libraryUserRatingLabel;

  /// Button to remove the user's personal rating
  ///
  /// In en, this message translates to:
  /// **'Clear rating'**
  String get libraryRatingClear;

  /// Label for the user's personal review/notes section in the library detail view
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get libraryUserReviewLabel;

  /// Button shown when no personal note exists, prompting the user to add one
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get libraryAddNoteButton;

  /// CTA label on the rating card when no user rating exists
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get libraryRateAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
