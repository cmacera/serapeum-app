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
