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
}
