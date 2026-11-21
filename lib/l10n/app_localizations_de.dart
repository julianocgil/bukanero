// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get back => 'Zurück';

  @override
  String get now => 'Jetzt';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String errorPrefix(String error) {
    return 'Fehler: $error';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get favorites => 'Favoriten';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String categoriesCount(int count) {
    return '$count Kategorien';
  }

  @override
  String get searchCategory => 'Kategorie suchen';

  @override
  String categoriesOf(String section) {
    return 'Kategorien · $section';
  }

  @override
  String get liveChannels => 'Live-Sender';

  @override
  String get liveShort => 'Live';

  @override
  String get movies => 'Filme';

  @override
  String get series => 'Serien';

  @override
  String get nothingHere => 'Hier ist nichts';

  @override
  String get searchByName => 'Nach Namen suchen';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get shrinkList => 'Liste verkleinern (großes Video)';

  @override
  String get expandList => 'Liste vergrößern (kleines Video)';

  @override
  String get continueWatching => 'Weiterschauen';

  @override
  String get programGuide => 'Programmführer';

  @override
  String get channelOrProgram => 'Sender oder Sendung';

  @override
  String get oneHourBefore => 'Eine Stunde früher';

  @override
  String get oneHourAfter => 'Eine Stunde später';

  @override
  String get guideNoChannels => 'Kein Sender dieser Liste hat Programmdaten.';

  @override
  String channelsCount(int count) {
    return '$count Sender';
  }

  @override
  String get watchNow => 'Jetzt ansehen';

  @override
  String get openChannel => 'Sender öffnen';

  @override
  String get guideNotFound =>
      'Kein Programmführer (EPG) in der Liste oder auf ihrem Server gefunden.';

  @override
  String get guideDeferred =>
      'Programm: Aktualisierung verschoben, bis das Video stoppt';

  @override
  String get guideDownloading => 'Programmführer wird heruntergeladen...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Programm: $programmes Sendungen, $channels Sender mit Programm';
  }

  @override
  String guideError(String error) {
    return 'Programm: $error';
  }

  @override
  String get groupRepeatedVersions => 'Doppelte Versionen gruppieren';

  @override
  String get groupingSubtitle =>
      'HD, FHD, 4K, synchronisiert, mit Untertiteln... auf einer Karte';

  @override
  String get reviewGroups => 'Gruppierungen prüfen';

  @override
  String get reviewGroupsMenu => 'Gruppierungen prüfen…';

  @override
  String separatedGroups(int count) {
    return 'Getrennte Gruppen ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Getrennte Gruppen ($count)…';
  }

  @override
  String get noSeparatedGroups => 'Keine getrennten Gruppen.';

  @override
  String get regroup => 'Neu gruppieren';

  @override
  String get regroupAll => 'Alle neu gruppieren';

  @override
  String get separate => 'Trennen';

  @override
  String get allRegrouped => 'Alle Gruppen wurden wieder zusammengeführt.';

  @override
  String groupSeparated(String name) {
    return 'Gruppe „$name“ getrennt. Die Versionen erscheinen einzeln.';
  }

  @override
  String get versionsRegrouped => 'Versionen wieder zusammengeführt.';

  @override
  String versionsOfRegrouped(String name) {
    return 'Die Versionen von „$name“ wurden wieder zusammengeführt.';
  }

  @override
  String get preferredForgotten =>
      'Die bevorzugten Versionen wurden vergessen.';

  @override
  String get forgetPreferred => 'Bevorzugte Versionen vergessen';

  @override
  String reviewIntro(int count) {
    return '$count Gruppen wurden nur nach Name und Bild gebildet. Die nur nach Namen gebildeten stehen zuerst. Trenne, was nicht dasselbe ist.';
  }

  @override
  String get searchGroup => 'Gruppe suchen';

  @override
  String get nothingToReview => 'Hier gibt es nichts zu prüfen.';

  @override
  String get reasonSameTvgId => 'gleiche tvg-id';

  @override
  String get reasonSameTmdb => 'gleiche TMDB';

  @override
  String get reasonSameNameYear => 'gleicher Name und Jahr';

  @override
  String get reasonSameNameImage => 'gleicher Name und Bild';

  @override
  String get reasonSameNameGuide => 'gleicher Name und Programmsender';

  @override
  String get reasonSameNameNumber => 'gleicher Name mit Nummer';

  @override
  String get reasonSameName => 'gleicher Name';

  @override
  String get reasonNumberedFamily => 'nummerierte Reihe';

  @override
  String get versionDefault => 'Standard';

  @override
  String get options => 'Optionen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get unhide => 'Wieder einblenden';

  @override
  String get regroupVersions => 'Versionen wieder zusammenführen';

  @override
  String get addFavorite => 'Zu Favoriten';

  @override
  String get removeFavorite => 'Aus Favoriten entfernen';

  @override
  String get favorited => 'Favorit';

  @override
  String get chooseVersion => 'Version wählen';

  @override
  String get yourPreference => '(deine Wahl)';

  @override
  String get automatic => '(automatisch)';

  @override
  String get separateGroup => 'Diese Gruppe trennen';

  @override
  String get removeFromRecent => 'Aus Zuletzt entfernen';

  @override
  String get watch => 'Ansehen';

  @override
  String get versions => 'Versionen';

  @override
  String directedBy(String names) {
    return 'Regie: $names';
  }

  @override
  String castList(String names) {
    return 'Besetzung: $names';
  }

  @override
  String durationHours(int hours, String minutes) {
    return '$hours h $minutes';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String episodeN(int number) {
    return 'Folge $number';
  }

  @override
  String get specials => 'Specials';

  @override
  String seasonN(int number) {
    return 'Staffel $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons Staffel(n) · $episodes Folge(n)';
  }

  @override
  String get previousEpisodes => 'Vorherige Folgen';

  @override
  String get nextEpisodes => 'Nächste Folgen';

  @override
  String pageOf(int page, int pages) {
    return 'Seite $page von $pages';
  }

  @override
  String get lastWatched => 'Zuletzt';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Nächste Folge in $seconds s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'S$season F$episode';
  }

  @override
  String get back15 => '15 s zurück';

  @override
  String get forward15 => '15 s vor';

  @override
  String get previousEpisode => 'Vorherige Folge';

  @override
  String get nextEpisode => 'Nächste Folge';

  @override
  String get mute => 'Ton aus';

  @override
  String get unmute => 'Ton an';

  @override
  String liveStalledReconnecting(String name) {
    return '„$name“ hängt. Neu verbinden...';
  }

  @override
  String liveNotBack(String name) {
    return '„$name“ kam nicht zurück. Versuche es gleich noch einmal.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from hängt. Wechsle zu $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'Keine Version von „$name“ ließ sich gerade öffnen.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'Version $version ließ sich nicht öffnen. Versuche $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'Version $version ließ sich nicht öffnen';
  }

  @override
  String tryAnotherVersion(String name) {
    return 'Eine andere Version von „$name“ versuchen?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'Die Liste konnte nicht heruntergeladen werden ($error). Die vorherige Liste wird verwendet.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb MB heruntergeladen';
  }

  @override
  String mbOf(String received, String total) {
    return '$received von $total MB';
  }

  @override
  String get queued => 'In der Warteschlange...';

  @override
  String get connecting => 'Verbinde mit dem Server...';

  @override
  String get preparingList => 'Neue Liste wird vorbereitet...';

  @override
  String get listUpdatedAuto => 'Liste automatisch aktualisiert.';

  @override
  String get listUpdated => 'Liste aktualisiert.';

  @override
  String listUpdateFailed(String error) {
    return 'Die Liste konnte nicht aktualisiert werden ($error). Die vorherige bleibt.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'Die Liste konnte nicht aktualisiert werden ($error). Die vorherige bleibt; neuer Versuch in einer Stunde.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Liste wird aktualisiert: $progress (du kannst weitermachen)';
  }

  @override
  String get updatingList => 'Liste wird aktualisiert...';

  @override
  String get refreshListBackground => 'Liste aktualisieren (im Hintergrund)';

  @override
  String get firstDownload =>
      'Liste wird heruntergeladen und vorbereitet (dauert nur beim ersten Mal)...';

  @override
  String get metaNoServer =>
      'Der Server der Liste konnte nicht erkannt werden, um Bewertungen und Daten zu laden.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Bewertungen geladen: $rated von $movies Filmen, $ratedSeries von $series Serien.';
  }

  @override
  String metaError(String error) {
    return 'Bewertungen und Daten: $error';
  }

  @override
  String sortBy(String mode) {
    return 'Sortieren: $mode';
  }

  @override
  String get sortListOrder => 'Listenreihenfolge';

  @override
  String get sortListOrderReverse => 'Listenreihenfolge (umgekehrt)';

  @override
  String get sortRecent => 'Zuletzt hinzugefügt';

  @override
  String get sortRecentSeries => 'Zuletzt hinzugefügt oder aktualisiert';

  @override
  String get sortRating => 'Beste Bewertung';

  @override
  String get sortYear => 'Jahr (neueste)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (wird geladen...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (nicht verfügbar)';
  }

  @override
  String get profiles => 'Profile';

  @override
  String get newProfileMenu => 'Neues Profil...';

  @override
  String get editProfileMenu => 'Aktuelles Profil bearbeiten...';

  @override
  String get deleteProfileMenu => 'Aktuelles Profil löschen';

  @override
  String get createProfile => 'Profil erstellen';

  @override
  String deleteProfileTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteProfileBody =>
      'Die heruntergeladene Liste, der Programmführer und die ausgeblendeten Einträge dieses Profils werden ebenfalls gelöscht.';

  @override
  String get newProfile => 'Neues Profil';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get userName => 'Name des Nutzers';

  @override
  String get playlistField => 'M3U-Playlist (URL oder Dateipfad)';

  @override
  String get guideField =>
      'XMLTV-Programm (optional; leer = automatisch erkennen)';

  @override
  String get fillNameAndPlaylist => 'Gib den Namen und die Playlist ein.';

  @override
  String get playlistUrlHint =>
      'Verwende eine http(s)-URL oder einen Dateipfad.';

  @override
  String get guideUrlHint =>
      'Programm: verwende eine http(s)-URL oder eine XMLTV-Datei.';

  @override
  String get acceptInvalidCert =>
      'Ungültiges Zertifikat dieses Servers akzeptieren';

  @override
  String get acceptInvalidCertHint =>
      'Nur für Listen, denen du vertraust. Deaktiviert ist sicherer.';

  @override
  String get autoRefreshList => 'Liste automatisch aktualisieren';

  @override
  String get refresh6h => 'Alle 6 Stunden';

  @override
  String get refresh12h => 'Alle 12 Stunden';

  @override
  String get refresh24h => 'Alle 24 Stunden';

  @override
  String get refresh24hDefault => 'Alle 24 Stunden (Standard)';

  @override
  String get refresh2d => 'Alle 2 Tage';

  @override
  String get refreshWeekly => 'Einmal pro Woche';

  @override
  String get refreshNever => 'Nie (nur auf Wunsch)';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeNavy => 'Blau';

  @override
  String get themeBlack => 'Schwarz';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'System';

  @override
  String get accentGold => 'Gold';

  @override
  String get accentBlue => 'Blau';

  @override
  String get accentGreen => 'Grün';

  @override
  String get accentRed => 'Rot';

  @override
  String get accentPurple => 'Lila';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get listSection => 'Liste';

  @override
  String get refreshListNow => 'Liste jetzt aktualisieren';

  @override
  String get refreshGuideNow => 'Programm jetzt aktualisieren';

  @override
  String get repeatedVersions => 'Doppelte Versionen';

  @override
  String get display => 'Anzeige';

  @override
  String get showHidden => 'Ausgeblendete Einträge zeigen';

  @override
  String get perfMonitor => 'Leistungsmonitor (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Anzeige über dem Video und Verlauf in desempenho.csv';

  @override
  String get profileSection => 'Profil';

  @override
  String get editCurrentProfile => 'Aktuelles Profil bearbeiten';

  @override
  String perfLogAt(String path) {
    return 'Verlauf wird in $path gespeichert';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Oberfläche $fps FPS · $slow langsam · max. $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Video      $fps von $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Verworfen  $rate/s · $count in 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Puffer     $seconds s';
  }

  @override
  String get perfLoadingTag => ' · LÄDT';

  @override
  String get perfLegend => 'weiß: Oberfläche · blau: Video · rot: lädt';

  @override
  String get errCertHint =>
      'Wenn du diesem Server vertraust, aktiviere „Ungültiges Zertifikat dieses Servers akzeptieren“ unter Profil bearbeiten.';

  @override
  String get errSelfSigned =>
      'der Server verwendet ein selbstsigniertes Zertifikat.';

  @override
  String get errCertExpired =>
      'das Zertifikat des Servers ist abgelaufen (oder das Datum des Computers ist falsch).';

  @override
  String get errCertHost =>
      'das Zertifikat des Servers gehört zu einer anderen Domain.';

  @override
  String get errCertUnknownCa =>
      'das Zertifikat des Servers stammt von einer unbekannten Stelle.';

  @override
  String get errNoTls =>
      'der Server spricht auf diesem Port kein TLS; versuche http:// statt https://.';

  @override
  String get errTls => 'TLS-/Zertifikatsfehler beim Verbinden';

  @override
  String get errInvalidUrl => 'ungültige URL (verwende http:// oder https://)';

  @override
  String get errNoResponse => 'der Server antwortet nicht mehr';

  @override
  String get errDns =>
      'die Adresse des Servers konnte nicht aufgelöst werden (DNS). Dein Anbieter blockiert sie vielleicht, oder die Adresse hat sich geändert.';

  @override
  String errConnection(String detail) {
    return 'Verbindung fehlgeschlagen ($detail)';
  }

  @override
  String get errNetwork => 'Netzwerk';

  @override
  String get errIncomplete => 'der Download ist unvollständig';

  @override
  String errBadHttp(String detail) {
    return 'ungültige HTTP-Antwort: $detail';
  }

  @override
  String errForbidden(String status) {
    return 'der Server hat den Zugriff verweigert (HTTP $status). Prüfe Benutzername und Passwort oder ob die Liste abgelaufen ist.';
  }

  @override
  String get errEmpty => 'der Server hat eine leere Antwort geliefert';

  @override
  String errHttp(int code) {
    return 'der Server antwortete mit HTTP $code';
  }

  @override
  String get errTooSlow => 'der Server sendet die Daten zu langsam';

  @override
  String errTooLong(int minutes) {
    return 'der Download dauerte länger als $minutes Min. und wurde abgebrochen';
  }

  @override
  String get errGuideFileNotFound => 'Programmdatei nicht gefunden';

  @override
  String get errGuideFormat => 'Programmformat nicht erkannt';

  @override
  String get errNoGuideSource => 'keine Programmquelle verfügbar';

  @override
  String get errServerResponse => 'Serverantwort nicht erkannt';

  @override
  String get errNoMeta => 'der Server lieferte weder Bewertungen noch Daten';
}
