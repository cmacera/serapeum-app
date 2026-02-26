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
}
