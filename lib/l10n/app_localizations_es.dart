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

  @override
  String get queryFailed =>
      'Lo siento, no he podido procesar tu solicitud en este momento. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get outOfScopeTitle => 'Fuera de alcance';

  @override
  String get errorTitle => 'Error del Oráculo';

  @override
  String get ok => 'Aceptar';

  @override
  String get networkError =>
      'Error de red. Por favor, comprueba tu conexión a internet.';

  @override
  String get timeoutError =>
      'La solicitud ha caducado. El Oráculo está ocupado o la conexión es lenta.';

  @override
  String serverError(int code) {
    return 'El servidor devolvió un error ($code).';
  }

  @override
  String get consultingOracle => 'Consultando al Oráculo...';

  @override
  String elapsedSecondsLabel(int seconds) {
    return '${seconds}s transcurridos';
  }

  @override
  String get filterAll => 'Todo';

  @override
  String get filterMedia => 'Cine y TV';

  @override
  String get filterBooks => 'Libros';

  @override
  String get filterGames => 'Juegos';
}
