// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SERAPEUM';

  @override
  String get myLibraryTitle => 'Mi Biblioteca';

  @override
  String get discoverTitle => 'Descubrir';

  @override
  String get controlCenterTitle => 'Centro de Control';

  @override
  String get askOracleHint => 'Pregúntale al Oráculo...';

  @override
  String get askOracleTooltip => 'Preguntar al Oráculo';

  @override
  String get discoveryHistoryTitle => 'Historial';

  @override
  String get clearHistory => 'Limpiar Historial';

  @override
  String get newConversation => 'Nueva Conversación';

  @override
  String get noHistory => 'No hay historial aún';

  @override
  String get clearHistoryConfirmation =>
      '¿Estás seguro de que quieres borrar todo el historial de búsqueda?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get noResponseFromOracle => 'No hay respuesta del Oráculo.';

  @override
  String get resultIntro =>
      'Esto es lo que he encontrado específicamente para tu petición:';

  @override
  String oracleErrorTemplate(String error, String details) {
    return 'El Oráculo encontró un error: $error$details';
  }

  @override
  String get noMatches =>
      'No se encontraron elementos coincidentes en los catálogos.';

  @override
  String queryError(String error) {
    return 'Error al consultar al Oráculo: $error';
  }

  @override
  String get unknownMedia => 'Medio desconocido';

  @override
  String bookSubtitle(String date) {
    return 'LIBRO · $date';
  }

  @override
  String get unknownYear => 'Año desconocido';

  @override
  String get gameSubtitle => 'JUEGO';
}
