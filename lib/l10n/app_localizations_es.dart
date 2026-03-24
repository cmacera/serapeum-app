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
  String get deleteHistoryItem => 'Eliminar';

  @override
  String get deleteHistoryItemConfirmation =>
      '¿Estás seguro de que quieres eliminar esta entrada del historial?';

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
  String searchElapsedSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String get filterAll => 'Todo';

  @override
  String get filterMedia => 'Cine y TV';

  @override
  String get filterBooks => 'Libros';

  @override
  String get filterGames => 'Juegos';

  @override
  String get mediaTypeMovie => 'PELÍCULA';

  @override
  String get mediaTypeTv => 'SERIE';

  @override
  String get mediaTypeUnknown => 'MULTIMEDIA';

  @override
  String get detailSynopsis => 'Sinopsis';

  @override
  String get detailPublishingInfo => 'Información de publicación';

  @override
  String get detailAuthors => 'Autores';

  @override
  String get detailPublisher => 'Editorial';

  @override
  String get detailPlatforms => 'Plataformas';

  @override
  String get detailGenres => 'Géneros';

  @override
  String get detailDevelopers => 'Desarrolladores';

  @override
  String get detailDefaultTitle => 'Detalles';

  @override
  String get unknownPublisher => 'Editorial desconocida';

  @override
  String get unknownAuthors => 'Desconocido';

  @override
  String get genreAction => 'Acción';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreAnimation => 'Animación';

  @override
  String get genreComedy => 'Comedia';

  @override
  String get genreCrime => 'Crimen';

  @override
  String get genreDocumentary => 'Documental';

  @override
  String get genreDrama => 'Drama';

  @override
  String get genreFamily => 'Familiar';

  @override
  String get genreFantasy => 'Fantasía';

  @override
  String get genreHistory => 'Historia';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genreMusic => 'Música';

  @override
  String get genreMystery => 'Misterio';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreSciFi => 'Ciencia ficción';

  @override
  String get genreTvMovie => 'Película de TV';

  @override
  String get genreThriller => 'Suspense';

  @override
  String get genreWar => 'Bélica';

  @override
  String get genreWestern => 'Western';

  @override
  String get genreActionAdventure => 'Acción y aventura';

  @override
  String get genreKids => 'Infantil';

  @override
  String get genreNews => 'Noticias';

  @override
  String get genreReality => 'Reality';

  @override
  String get genreSciFiFantasy => 'Ciencia ficción y fantasía';

  @override
  String get genreSoap => 'Telenovela';

  @override
  String get genreTalk => 'Programa de entrevistas';

  @override
  String get genreWarPolitics => 'Guerra y política';

  @override
  String get detailOriginalLanguage => 'Idioma';

  @override
  String get detailThemes => 'Temáticas';

  @override
  String get detailGameModes => 'Modos de juego';

  @override
  String get detailAgeRatings => 'Clasificación de edad';

  @override
  String get detailSimilarGames => 'Juegos similares';

  @override
  String get detailAverageRating => 'Valoración de usuarios';

  @override
  String get detailMaturityRating => 'Clasificación de madurez';

  @override
  String get maturityRatingForAll => 'Para todos los públicos';

  @override
  String get maturityRatingMature => 'Contenido para adultos';

  @override
  String get detailScreenshots => 'Capturas de pantalla';

  @override
  String get detailTrailers => 'Tráilers';

  @override
  String get playTrailer => 'Reproducir tráiler';

  @override
  String get viewScreenshot => 'Ver captura de pantalla';

  @override
  String get detailIsbn => 'ISBN';

  @override
  String get detailCast => 'Reparto';

  @override
  String get detailWhereToWatch => 'Dónde ver';

  @override
  String get detailWatchStream => 'Streaming';

  @override
  String get detailWatchRent => 'Alquilar';

  @override
  String get detailWatchBuy => 'Comprar';

  @override
  String get detailSeasons => 'Temporadas';

  @override
  String get detailNetworks => 'Cadenas';

  @override
  String get detailCreators => 'Creadores';

  @override
  String get detailRuntime => 'Duración';

  @override
  String get detailTagline => 'Eslogan';

  @override
  String detailTaglineQuoted(String tagline) {
    return '\"$tagline\"';
  }

  @override
  String get detailBudget => 'Presupuesto';

  @override
  String get detailRevenue => 'Recaudación';

  @override
  String get detailLoadingEnriched => 'Cargando detalles…';

  @override
  String get detailEnrichmentError =>
      'No se pudieron cargar los detalles adicionales';

  @override
  String detailEpisodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
    );
    return '$_temp0';
  }

  @override
  String get saveToLibrary => 'Guardar en Biblioteca';

  @override
  String get removeFromLibrary => 'Eliminar de Biblioteca';

  @override
  String get libraryEmpty =>
      'Tu Biblioteca está vacía.\nGuarda elementos desde el Oráculo para empezar.';

  @override
  String get sortOptions => 'Ordenar por';

  @override
  String get sortByDateDesc => 'Más recientes primero';

  @override
  String get sortByDateAsc => 'Más antiguos primero';

  @override
  String get sortByTitle => 'Título (A–Z)';

  @override
  String get sortByRating => 'Mejor valorados';

  @override
  String get sortByType => 'Por tipo';

  @override
  String get searchLibraryHint => 'Buscar en biblioteca...';

  @override
  String get searchLibraryTooltip => 'Buscar';

  @override
  String get libraryNoSearchResults =>
      'Ningún elemento coincide con tu búsqueda.';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get libraryUserRatingLabel => 'Tu valoración';

  @override
  String get libraryRatingClear => 'Borrar valoración';

  @override
  String get libraryUserReviewLabel => 'Tu reseña';

  @override
  String get libraryAddNoteButton => 'Añadir nota';

  @override
  String get libraryRateAction => 'Valorar';

  @override
  String get libraryWatched => 'Visto';

  @override
  String get libraryRead => 'Leído';

  @override
  String get libraryPlayed => 'Jugado';

  @override
  String get libraryMarkAsWatched => 'Marcar como visto';

  @override
  String get libraryMarkAsRead => 'Marcar como leído';

  @override
  String get libraryMarkAsPlayed => 'Marcar como jugado';

  @override
  String get authInitializationError =>
      'Error de conexión. La aplicación no pudo conectarse al servidor. Por favor, comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';
}
