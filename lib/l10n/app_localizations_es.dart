// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get back => 'Volver';

  @override
  String get now => 'Ahora';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get favorites => 'Favoritos';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String categoriesCount(int count) {
    return '$count categorías';
  }

  @override
  String get searchCategory => 'Buscar categoría';

  @override
  String categoriesOf(String section) {
    return 'Categorías · $section';
  }

  @override
  String get liveChannels => 'Canales en vivo';

  @override
  String get liveShort => 'En vivo';

  @override
  String get movies => 'Películas';

  @override
  String get series => 'Series';

  @override
  String get nothingHere => 'Nada por aquí';

  @override
  String get searchByName => 'Buscar por nombre';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get shrinkList => 'Reducir la lista (video grande)';

  @override
  String get expandList => 'Ampliar la lista (video pequeño)';

  @override
  String get continueWatching => 'Seguir viendo';

  @override
  String get programGuide => 'Guía de programación';

  @override
  String get channelOrProgram => 'Canal o programa';

  @override
  String get oneHourBefore => 'Una hora antes';

  @override
  String get oneHourAfter => 'Una hora después';

  @override
  String get guideNoChannels =>
      'Ningún canal de esta lista tiene programación en la guía.';

  @override
  String channelsCount(int count) {
    return '$count canales';
  }

  @override
  String get watchNow => 'Ver ahora';

  @override
  String get openChannel => 'Abrir el canal';

  @override
  String get guideNotFound =>
      'No encontré la guía (EPG) ni en la lista ni en su servidor.';

  @override
  String get guideDeferred =>
      'Guía: actualización aplazada hasta que pare el video';

  @override
  String get guideDownloading => 'Descargando la guía de programación...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Guía: $programmes programas, $channels canales con programación';
  }

  @override
  String guideError(String error) {
    return 'Guía: $error';
  }

  @override
  String get groupRepeatedVersions => 'Agrupar versiones repetidas';

  @override
  String get groupingSubtitle =>
      'HD, FHD, 4K, doblado, subtitulado... en una sola tarjeta';

  @override
  String get reviewGroups => 'Revisar agrupaciones';

  @override
  String get reviewGroupsMenu => 'Revisar agrupaciones…';

  @override
  String separatedGroups(int count) {
    return 'Grupos separados ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Grupos separados ($count)…';
  }

  @override
  String get noSeparatedGroups => 'Ningún grupo separado.';

  @override
  String get regroup => 'Reagrupar';

  @override
  String get regroupAll => 'Reagrupar todos';

  @override
  String get separate => 'Separar';

  @override
  String get allRegrouped => 'Todos los grupos se juntaron de nuevo.';

  @override
  String groupSeparated(String name) {
    return 'Grupo \"$name\" separado. Las versiones aparecen sueltas.';
  }

  @override
  String get versionsRegrouped => 'Versiones juntadas de nuevo.';

  @override
  String versionsOfRegrouped(String name) {
    return 'Las versiones de \"$name\" se juntaron de nuevo.';
  }

  @override
  String get preferredForgotten => 'Se olvidaron las versiones preferidas.';

  @override
  String get forgetPreferred => 'Olvidar versiones preferidas';

  @override
  String reviewIntro(int count) {
    return '$count grupos se juntaron solo por nombre e imagen. Los juntados solo por el nombre aparecen primero. Separa lo que no sea lo mismo.';
  }

  @override
  String get searchGroup => 'Buscar grupo';

  @override
  String get nothingToReview => 'Nada que revisar aquí.';

  @override
  String get reasonSameTvgId => 'mismo tvg-id';

  @override
  String get reasonSameTmdb => 'mismo TMDB';

  @override
  String get reasonSameNameYear => 'mismo nombre y año';

  @override
  String get reasonSameNameImage => 'mismo nombre e imagen';

  @override
  String get reasonSameNameGuide => 'mismo nombre y canal de la guía';

  @override
  String get reasonSameNameNumber => 'mismo nombre con número';

  @override
  String get reasonSameName => 'mismo nombre';

  @override
  String get reasonNumberedFamily => 'familia numerada';

  @override
  String get versionDefault => 'Estándar';

  @override
  String get options => 'Opciones';

  @override
  String get hide => 'Ocultar';

  @override
  String get unhide => 'Mostrar de nuevo';

  @override
  String get regroupVersions => 'Juntar las versiones de nuevo';

  @override
  String get addFavorite => 'Añadir a favoritos';

  @override
  String get removeFavorite => 'Quitar de favoritos';

  @override
  String get favorited => 'Favorito';

  @override
  String get chooseVersion => 'Elegir la versión';

  @override
  String get yourPreference => '(tu preferencia)';

  @override
  String get automatic => '(automática)';

  @override
  String get separateGroup => 'Separar este grupo';

  @override
  String get removeFromRecent => 'Quitar de recientes';

  @override
  String get watch => 'Ver';

  @override
  String get versions => 'Versiones';

  @override
  String directedBy(String names) {
    return 'Dirección: $names';
  }

  @override
  String castList(String names) {
    return 'Reparto: $names';
  }

  @override
  String durationHours(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String episodeN(int number) {
    return 'Episodio $number';
  }

  @override
  String get specials => 'Especiales';

  @override
  String seasonN(int number) {
    return 'Temporada $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons temporada(s) · $episodes episodio(s)';
  }

  @override
  String get previousEpisodes => 'Episodios anteriores';

  @override
  String get nextEpisodes => 'Próximos episodios';

  @override
  String pageOf(int page, int pages) {
    return 'Página $page de $pages';
  }

  @override
  String get lastWatched => 'Último';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Próximo episodio en ${seconds}s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'T$season E$episode';
  }

  @override
  String get back15 => 'Retroceder 15 s';

  @override
  String get forward15 => 'Avanzar 15 s';

  @override
  String get previousEpisode => 'Episodio anterior';

  @override
  String get nextEpisode => 'Próximo episodio';

  @override
  String get mute => 'Silenciar';

  @override
  String get unmute => 'Activar sonido';

  @override
  String liveStalledReconnecting(String name) {
    return '\"$name\" se congeló. Reconectando...';
  }

  @override
  String liveNotBack(String name) {
    return '\"$name\" no volvió. Inténtalo de nuevo en un rato.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from se congeló. Cambiando a $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'Ninguna versión de \"$name\" abrió ahora.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'La versión $version no abrió. Probando $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'La versión $version no abrió';
  }

  @override
  String tryAnotherVersion(String name) {
    return '¿Probar otra versión de \"$name\"?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'No pude descargar la lista ($error). Uso la lista anterior.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb MB descargados';
  }

  @override
  String mbOf(String received, String total) {
    return '$received de $total MB';
  }

  @override
  String get queued => 'En cola...';

  @override
  String get connecting => 'Conectando al servidor...';

  @override
  String get preparingList => 'Preparando la lista nueva...';

  @override
  String get listUpdatedAuto => 'Lista actualizada automáticamente.';

  @override
  String get listUpdated => 'Lista actualizada.';

  @override
  String listUpdateFailed(String error) {
    return 'No pude actualizar la lista ($error). Sigo con la anterior.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'No pude actualizar la lista ($error). Sigo con la anterior; lo intento de nuevo en una hora.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Actualizando la lista: $progress (puedes seguir usando la app)';
  }

  @override
  String get updatingList => 'Actualizando la lista...';

  @override
  String get refreshListBackground => 'Actualizar la lista (en segundo plano)';

  @override
  String get firstDownload =>
      'Descargando y preparando la lista (solo tarda la primera vez)...';

  @override
  String get metaNoServer =>
      'No pude identificar el servidor de la lista para buscar notas y fechas.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Notas cargadas: $rated de $movies películas, $ratedSeries de $series series.';
  }

  @override
  String metaError(String error) {
    return 'Notas y fechas: $error';
  }

  @override
  String sortBy(String mode) {
    return 'Ordenar: $mode';
  }

  @override
  String get sortListOrder => 'Orden de la lista';

  @override
  String get sortListOrderReverse => 'Orden de la lista (invertido)';

  @override
  String get sortRecent => 'Añadidos recientemente';

  @override
  String get sortRecentSeries => 'Añadidas o actualizadas recientemente';

  @override
  String get sortRating => 'Mejor nota';

  @override
  String get sortYear => 'Año (más reciente)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (cargando...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (no disponible)';
  }

  @override
  String get profiles => 'Perfiles';

  @override
  String get newProfileMenu => 'Nuevo perfil...';

  @override
  String get editProfileMenu => 'Editar perfil actual...';

  @override
  String get deleteProfileMenu => 'Eliminar perfil actual';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String deleteProfileTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteProfileBody =>
      'También se borrarán la lista descargada, la guía y los elementos ocultos de este perfil.';

  @override
  String get newProfile => 'Nuevo perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get userName => 'Nombre del usuario';

  @override
  String get playlistField => 'Lista M3U (URL o ruta del archivo)';

  @override
  String get guideField => 'Guía XMLTV (opcional; vacío = detectar sola)';

  @override
  String get fillNameAndPlaylist => 'Completa el nombre y la lista.';

  @override
  String get playlistUrlHint => 'Usa una URL http(s) o la ruta de un archivo.';

  @override
  String get guideUrlHint => 'Guía: usa una URL http(s) o un archivo XMLTV.';

  @override
  String get acceptInvalidCert =>
      'Aceptar el certificado inválido de este servidor';

  @override
  String get acceptInvalidCertHint =>
      'Solo para listas en las que confías. Desmarcado es más seguro.';

  @override
  String get autoRefreshList => 'Actualizar la lista sola';

  @override
  String get refresh6h => 'Cada 6 horas';

  @override
  String get refresh12h => 'Cada 12 horas';

  @override
  String get refresh24h => 'Cada 24 horas';

  @override
  String get refresh24hDefault => 'Cada 24 horas (predeterminado)';

  @override
  String get refresh2d => 'Cada 2 días';

  @override
  String get refreshWeekly => 'Una vez por semana';

  @override
  String get refreshNever => 'Nunca (solo cuando lo pida)';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeNavy => 'Azul';

  @override
  String get themeBlack => 'Negro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Del sistema';

  @override
  String get accentGold => 'Dorado';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentRed => 'Rojo';

  @override
  String get accentPurple => 'Morado';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Del sistema';

  @override
  String get listSection => 'Lista';

  @override
  String get refreshListNow => 'Actualizar la lista ahora';

  @override
  String get refreshGuideNow => 'Actualizar la guía ahora';

  @override
  String get repeatedVersions => 'Versiones repetidas';

  @override
  String get display => 'Visualización';

  @override
  String get showHidden => 'Mostrar elementos ocultos';

  @override
  String get perfMonitor => 'Monitor de rendimiento (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Panel sobre el video e historial en desempenho.csv';

  @override
  String get profileSection => 'Perfil';

  @override
  String get editCurrentProfile => 'Editar perfil actual';

  @override
  String perfLogAt(String path) {
    return 'Guardando el historial en $path';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Interfaz   $fps FPS · $slow lentos · peor $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Video      $fps de $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Descartes  $rate/s · $count en 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Reserva    $seconds s';
  }

  @override
  String get perfLoadingTag => ' · CARGANDO';

  @override
  String get perfLegend => 'blanco: interfaz · azul: video · rojo: cargando';

  @override
  String get errCertHint =>
      'Si confías en este servidor, marca \"Aceptar el certificado inválido de este servidor\" en Editar perfil.';

  @override
  String get errSelfSigned => 'el servidor usa un certificado autofirmado.';

  @override
  String get errCertExpired =>
      'el certificado del servidor está vencido (o la fecha del equipo es incorrecta).';

  @override
  String get errCertHost => 'el certificado del servidor es de otro dominio.';

  @override
  String get errCertUnknownCa =>
      'el certificado del servidor viene de una autoridad desconocida.';

  @override
  String get errNoTls =>
      'el servidor no usa TLS en este puerto; prueba http:// en lugar de https://.';

  @override
  String get errTls => 'error de TLS/certificado al conectar';

  @override
  String get errInvalidUrl => 'URL inválida (usa http:// o https://)';

  @override
  String get errNoResponse => 'el servidor dejó de responder';

  @override
  String get errDns =>
      'no se pudo resolver la dirección del servidor (DNS). Tu proveedor puede estar bloqueándola, o la dirección cambió.';

  @override
  String errConnection(String detail) {
    return 'fallo de conexión ($detail)';
  }

  @override
  String get errNetwork => 'red';

  @override
  String get errIncomplete => 'la descarga llegó incompleta';

  @override
  String errBadHttp(String detail) {
    return 'respuesta HTTP inválida: $detail';
  }

  @override
  String errForbidden(String status) {
    return 'el servidor rechazó el acceso (HTTP $status). Revisa usuario y contraseña, o si la lista caducó.';
  }

  @override
  String get errEmpty => 'el servidor devolvió una respuesta vacía';

  @override
  String errHttp(int code) {
    return 'el servidor respondió HTTP $code';
  }

  @override
  String get errTooSlow =>
      'el servidor está enviando los datos demasiado despacio';

  @override
  String errTooLong(int minutes) {
    return 'la descarga pasó de $minutes min y se canceló';
  }

  @override
  String get errGuideFileNotFound => 'archivo de la guía no encontrado';

  @override
  String get errGuideFormat => 'formato de la guía no reconocido';

  @override
  String get errNoGuideSource => 'ninguna fuente de guía disponible';

  @override
  String get errServerResponse => 'respuesta del servidor no reconocida';

  @override
  String get errNoMeta => 'el servidor no devolvió notas ni fechas';
}
