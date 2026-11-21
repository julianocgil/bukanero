// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get close => 'Chiudi';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get back => 'Indietro';

  @override
  String get now => 'Adesso';

  @override
  String get tryAgain => 'Riprova';

  @override
  String errorPrefix(String error) {
    return 'Errore: $error';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get favorites => 'Preferiti';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String categoriesCount(int count) {
    return '$count categorie';
  }

  @override
  String get searchCategory => 'Cerca categoria';

  @override
  String categoriesOf(String section) {
    return 'Categorie · $section';
  }

  @override
  String get liveChannels => 'Canali in diretta';

  @override
  String get liveShort => 'Diretta';

  @override
  String get movies => 'Film';

  @override
  String get series => 'Serie';

  @override
  String get nothingHere => 'Niente qui';

  @override
  String get searchByName => 'Cerca per nome';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get shrinkList => 'Riduci la lista (video grande)';

  @override
  String get expandList => 'Allarga la lista (video piccolo)';

  @override
  String get continueWatching => 'Continua a guardare';

  @override
  String get programGuide => 'Guida TV';

  @override
  String get channelOrProgram => 'Canale o programma';

  @override
  String get oneHourBefore => 'Un\'ora prima';

  @override
  String get oneHourAfter => 'Un\'ora dopo';

  @override
  String get guideNoChannels =>
      'Nessun canale di questa lista ha programmi nella guida.';

  @override
  String channelsCount(int count) {
    return '$count canali';
  }

  @override
  String get watchNow => 'Guarda ora';

  @override
  String get openChannel => 'Apri il canale';

  @override
  String get guideNotFound =>
      'Guida (EPG) non trovata né nella lista né sul suo server.';

  @override
  String get guideDeferred =>
      'Guida: aggiornamento rinviato finché il video non si ferma';

  @override
  String get guideDownloading => 'Download della guida TV...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Guida: $programmes programmi, $channels canali con programmazione';
  }

  @override
  String guideError(String error) {
    return 'Guida: $error';
  }

  @override
  String get groupRepeatedVersions => 'Raggruppa versioni ripetute';

  @override
  String get groupingSubtitle =>
      'HD, FHD, 4K, doppiato, sottotitolato... in una sola scheda';

  @override
  String get reviewGroups => 'Controlla i raggruppamenti';

  @override
  String get reviewGroupsMenu => 'Controlla i raggruppamenti…';

  @override
  String separatedGroups(int count) {
    return 'Gruppi separati ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Gruppi separati ($count)…';
  }

  @override
  String get noSeparatedGroups => 'Nessun gruppo separato.';

  @override
  String get regroup => 'Raggruppa';

  @override
  String get regroupAll => 'Raggruppa tutti';

  @override
  String get separate => 'Separa';

  @override
  String get allRegrouped => 'Tutti i gruppi sono stati riuniti.';

  @override
  String groupSeparated(String name) {
    return 'Gruppo \"$name\" separato. Le versioni appaiono singolarmente.';
  }

  @override
  String get versionsRegrouped => 'Versioni riunite.';

  @override
  String versionsOfRegrouped(String name) {
    return 'Le versioni di \"$name\" sono state riunite.';
  }

  @override
  String get preferredForgotten =>
      'Le versioni preferite sono state dimenticate.';

  @override
  String get forgetPreferred => 'Dimentica le versioni preferite';

  @override
  String reviewIntro(int count) {
    return '$count gruppi sono stati formati solo per nome e immagine. Quelli formati solo per nome vengono prima. Separa ciò che non è la stessa cosa.';
  }

  @override
  String get searchGroup => 'Cerca gruppo';

  @override
  String get nothingToReview => 'Niente da controllare qui.';

  @override
  String get reasonSameTvgId => 'stesso tvg-id';

  @override
  String get reasonSameTmdb => 'stesso TMDB';

  @override
  String get reasonSameNameYear => 'stesso nome e anno';

  @override
  String get reasonSameNameImage => 'stesso nome e immagine';

  @override
  String get reasonSameNameGuide => 'stesso nome e canale della guida';

  @override
  String get reasonSameNameNumber => 'stesso nome con numero';

  @override
  String get reasonSameName => 'stesso nome';

  @override
  String get reasonNumberedFamily => 'serie numerata';

  @override
  String get versionDefault => 'Standard';

  @override
  String get options => 'Opzioni';

  @override
  String get hide => 'Nascondi';

  @override
  String get unhide => 'Mostra di nuovo';

  @override
  String get regroupVersions => 'Riunisci le versioni';

  @override
  String get addFavorite => 'Aggiungi ai preferiti';

  @override
  String get removeFavorite => 'Togli dai preferiti';

  @override
  String get favorited => 'Preferito';

  @override
  String get chooseVersion => 'Scegli la versione';

  @override
  String get yourPreference => '(tua preferenza)';

  @override
  String get automatic => '(automatica)';

  @override
  String get separateGroup => 'Separa questo gruppo';

  @override
  String get removeFromRecent => 'Togli dai recenti';

  @override
  String get watch => 'Guarda';

  @override
  String get versions => 'Versioni';

  @override
  String directedBy(String names) {
    return 'Regia: $names';
  }

  @override
  String castList(String names) {
    return 'Cast: $names';
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
  String get specials => 'Speciali';

  @override
  String seasonN(int number) {
    return 'Stagione $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons stagione/i · $episodes episodio/i';
  }

  @override
  String get previousEpisodes => 'Episodi precedenti';

  @override
  String get nextEpisodes => 'Prossimi episodi';

  @override
  String pageOf(int page, int pages) {
    return 'Pagina $page di $pages';
  }

  @override
  String get lastWatched => 'Ultimo';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Prossimo episodio tra $seconds s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'S$season E$episode';
  }

  @override
  String get back15 => 'Indietro di 15 s';

  @override
  String get forward15 => 'Avanti di 15 s';

  @override
  String get previousEpisode => 'Episodio precedente';

  @override
  String get nextEpisode => 'Prossimo episodio';

  @override
  String get mute => 'Disattiva audio';

  @override
  String get unmute => 'Attiva audio';

  @override
  String liveStalledReconnecting(String name) {
    return '\"$name\" si è bloccato. Riconnessione...';
  }

  @override
  String liveNotBack(String name) {
    return '\"$name\" non è tornato. Riprova tra poco.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from si è bloccato. Passo a $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'Nessuna versione di \"$name\" si è aperta.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'La versione $version non si è aperta. Provo $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'La versione $version non si è aperta';
  }

  @override
  String tryAnotherVersion(String name) {
    return 'Provare un\'altra versione di \"$name\"?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'Impossibile scaricare la lista ($error). Uso la lista precedente.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb MB scaricati';
  }

  @override
  String mbOf(String received, String total) {
    return '$received di $total MB';
  }

  @override
  String get queued => 'In coda...';

  @override
  String get connecting => 'Connessione al server...';

  @override
  String get preparingList => 'Preparazione della nuova lista...';

  @override
  String get listUpdatedAuto => 'Lista aggiornata automaticamente.';

  @override
  String get listUpdated => 'Lista aggiornata.';

  @override
  String listUpdateFailed(String error) {
    return 'Impossibile aggiornare la lista ($error). Continuo con la precedente.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'Impossibile aggiornare la lista ($error). Continuo con la precedente; riprovo tra un\'ora.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Aggiornamento della lista: $progress (puoi continuare a usare l\'app)';
  }

  @override
  String get updatingList => 'Aggiornamento della lista...';

  @override
  String get refreshListBackground => 'Aggiorna la lista (in background)';

  @override
  String get firstDownload =>
      'Download e preparazione della lista (lento solo la prima volta)...';

  @override
  String get metaNoServer =>
      'Impossibile identificare il server della lista per ottenere voti e date.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Voti caricati: $rated di $movies film, $ratedSeries di $series serie.';
  }

  @override
  String metaError(String error) {
    return 'Voti e date: $error';
  }

  @override
  String sortBy(String mode) {
    return 'Ordina: $mode';
  }

  @override
  String get sortListOrder => 'Ordine della lista';

  @override
  String get sortListOrderReverse => 'Ordine della lista (invertito)';

  @override
  String get sortRecent => 'Aggiunti di recente';

  @override
  String get sortRecentSeries => 'Aggiunte o aggiornate di recente';

  @override
  String get sortRating => 'Voto migliore';

  @override
  String get sortYear => 'Anno (più recente)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (caricamento...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (non disponibile)';
  }

  @override
  String get profiles => 'Profili';

  @override
  String get newProfileMenu => 'Nuovo profilo...';

  @override
  String get editProfileMenu => 'Modifica profilo attuale...';

  @override
  String get deleteProfileMenu => 'Elimina profilo attuale';

  @override
  String get createProfile => 'Crea profilo';

  @override
  String deleteProfileTitle(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get deleteProfileBody =>
      'Verranno eliminati anche la lista scaricata, la guida e gli elementi nascosti di questo profilo.';

  @override
  String get newProfile => 'Nuovo profilo';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get userName => 'Nome dell\'utente';

  @override
  String get playlistField => 'Playlist M3U (URL o percorso del file)';

  @override
  String get guideField =>
      'Guida XMLTV (facoltativa; vuoto = rilevamento automatico)';

  @override
  String get fillNameAndPlaylist => 'Inserisci il nome e la playlist.';

  @override
  String get playlistUrlHint => 'Usa un URL http(s) o il percorso di un file.';

  @override
  String get guideUrlHint => 'Guida: usa un URL http(s) o un file XMLTV.';

  @override
  String get acceptInvalidCert =>
      'Accetta il certificato non valido di questo server';

  @override
  String get acceptInvalidCertHint =>
      'Solo per liste di cui ti fidi. Non selezionato è più sicuro.';

  @override
  String get autoRefreshList => 'Aggiorna la lista automaticamente';

  @override
  String get refresh6h => 'Ogni 6 ore';

  @override
  String get refresh12h => 'Ogni 12 ore';

  @override
  String get refresh24h => 'Ogni 24 ore';

  @override
  String get refresh24hDefault => 'Ogni 24 ore (predefinito)';

  @override
  String get refresh2d => 'Ogni 2 giorni';

  @override
  String get refreshWeekly => 'Una volta a settimana';

  @override
  String get refreshNever => 'Mai (solo quando lo chiedo)';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeNavy => 'Blu';

  @override
  String get themeBlack => 'Nero';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeSystem => 'Di sistema';

  @override
  String get accentGold => 'Oro';

  @override
  String get accentBlue => 'Blu';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentRed => 'Rosso';

  @override
  String get accentPurple => 'Viola';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Di sistema';

  @override
  String get listSection => 'Lista';

  @override
  String get refreshListNow => 'Aggiorna la lista ora';

  @override
  String get refreshGuideNow => 'Aggiorna la guida ora';

  @override
  String get repeatedVersions => 'Versioni ripetute';

  @override
  String get display => 'Visualizzazione';

  @override
  String get showHidden => 'Mostra elementi nascosti';

  @override
  String get perfMonitor => 'Monitor delle prestazioni (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Pannello sul video e cronologia in desempenho.csv';

  @override
  String get profileSection => 'Profilo';

  @override
  String get editCurrentProfile => 'Modifica profilo attuale';

  @override
  String perfLogAt(String path) {
    return 'Registro la cronologia in $path';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Interfaccia $fps FPS · $slow lenti · peggiore $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Video      $fps di $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Scartati   $rate/s · $count in 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Buffer     $seconds s';
  }

  @override
  String get perfLoadingTag => ' · CARICAMENTO';

  @override
  String get perfLegend =>
      'bianco: interfaccia · blu: video · rosso: caricamento';

  @override
  String get errCertHint =>
      'Se ti fidi di questo server, seleziona \"Accetta il certificato non valido di questo server\" in Modifica profilo.';

  @override
  String get errSelfSigned => 'il server usa un certificato autofirmato.';

  @override
  String get errCertExpired =>
      'il certificato del server è scaduto (o la data del computer è sbagliata).';

  @override
  String get errCertHost =>
      'il certificato del server appartiene a un altro dominio.';

  @override
  String get errCertUnknownCa =>
      'il certificato del server proviene da un\'autorità sconosciuta.';

  @override
  String get errNoTls =>
      'il server non usa TLS su questa porta; prova http:// invece di https://.';

  @override
  String get errTls => 'errore TLS/certificato durante la connessione';

  @override
  String get errInvalidUrl => 'URL non valido (usa http:// o https://)';

  @override
  String get errNoResponse => 'il server ha smesso di rispondere';

  @override
  String get errDns =>
      'impossibile risolvere l\'indirizzo del server (DNS). Il tuo operatore potrebbe bloccarlo, o l\'indirizzo è cambiato.';

  @override
  String errConnection(String detail) {
    return 'connessione non riuscita ($detail)';
  }

  @override
  String get errNetwork => 'rete';

  @override
  String get errIncomplete => 'il download è incompleto';

  @override
  String errBadHttp(String detail) {
    return 'risposta HTTP non valida: $detail';
  }

  @override
  String errForbidden(String status) {
    return 'il server ha rifiutato l\'accesso (HTTP $status). Controlla utente e password, o se la lista è scaduta.';
  }

  @override
  String get errEmpty => 'il server ha restituito una risposta vuota';

  @override
  String errHttp(int code) {
    return 'il server ha risposto HTTP $code';
  }

  @override
  String get errTooSlow => 'il server invia i dati troppo lentamente';

  @override
  String errTooLong(int minutes) {
    return 'il download ha superato $minutes min ed è stato annullato';
  }

  @override
  String get errGuideFileNotFound => 'file della guida non trovato';

  @override
  String get errGuideFormat => 'formato della guida non riconosciuto';

  @override
  String get errNoGuideSource => 'nessuna fonte di guida disponibile';

  @override
  String get errServerResponse => 'risposta del server non riconosciuta';

  @override
  String get errNoMeta => 'il server non ha restituito né voti né date';
}
