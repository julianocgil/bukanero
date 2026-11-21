// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get close => 'Fermer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get back => 'Retour';

  @override
  String get now => 'Maintenant';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String errorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get favorites => 'Favoris';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String categoriesCount(int count) {
    return '$count catégories';
  }

  @override
  String get searchCategory => 'Chercher une catégorie';

  @override
  String categoriesOf(String section) {
    return 'Catégories · $section';
  }

  @override
  String get liveChannels => 'Chaînes en direct';

  @override
  String get liveShort => 'Direct';

  @override
  String get movies => 'Films';

  @override
  String get series => 'Séries';

  @override
  String get nothingHere => 'Rien ici';

  @override
  String get searchByName => 'Chercher par nom';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get shrinkList => 'Réduire la liste (grande vidéo)';

  @override
  String get expandList => 'Agrandir la liste (petite vidéo)';

  @override
  String get continueWatching => 'Reprendre';

  @override
  String get programGuide => 'Guide des programmes';

  @override
  String get channelOrProgram => 'Chaîne ou programme';

  @override
  String get oneHourBefore => 'Une heure avant';

  @override
  String get oneHourAfter => 'Une heure après';

  @override
  String get guideNoChannels =>
      'Aucune chaîne de cette liste n\'a de programme dans le guide.';

  @override
  String channelsCount(int count) {
    return '$count chaînes';
  }

  @override
  String get watchNow => 'Regarder maintenant';

  @override
  String get openChannel => 'Ouvrir la chaîne';

  @override
  String get guideNotFound =>
      'Guide (EPG) introuvable, ni dans la liste ni sur son serveur.';

  @override
  String get guideDeferred =>
      'Guide : mise à jour reportée jusqu\'à l\'arrêt de la vidéo';

  @override
  String get guideDownloading => 'Téléchargement du guide des programmes...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Guide : $programmes programmes, $channels chaînes avec programme';
  }

  @override
  String guideError(String error) {
    return 'Guide : $error';
  }

  @override
  String get groupRepeatedVersions => 'Regrouper les versions répétées';

  @override
  String get groupingSubtitle => 'HD, FHD, 4K, VF, VOST... sur une seule carte';

  @override
  String get reviewGroups => 'Vérifier les regroupements';

  @override
  String get reviewGroupsMenu => 'Vérifier les regroupements…';

  @override
  String separatedGroups(int count) {
    return 'Groupes séparés ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Groupes séparés ($count)…';
  }

  @override
  String get noSeparatedGroups => 'Aucun groupe séparé.';

  @override
  String get regroup => 'Regrouper';

  @override
  String get regroupAll => 'Tout regrouper';

  @override
  String get separate => 'Séparer';

  @override
  String get allRegrouped => 'Tous les groupes ont été regroupés.';

  @override
  String groupSeparated(String name) {
    return 'Groupe « $name » séparé. Les versions apparaissent séparément.';
  }

  @override
  String get versionsRegrouped => 'Versions regroupées.';

  @override
  String versionsOfRegrouped(String name) {
    return 'Les versions de « $name » ont été regroupées.';
  }

  @override
  String get preferredForgotten => 'Les versions préférées ont été oubliées.';

  @override
  String get forgetPreferred => 'Oublier les versions préférées';

  @override
  String reviewIntro(int count) {
    return '$count groupes ont été formés uniquement par nom et image. Ceux formés par le nom seul viennent en premier. Séparez ce qui n\'est pas la même chose.';
  }

  @override
  String get searchGroup => 'Chercher un groupe';

  @override
  String get nothingToReview => 'Rien à vérifier ici.';

  @override
  String get reasonSameTvgId => 'même tvg-id';

  @override
  String get reasonSameTmdb => 'même TMDB';

  @override
  String get reasonSameNameYear => 'même nom et année';

  @override
  String get reasonSameNameImage => 'même nom et image';

  @override
  String get reasonSameNameGuide => 'même nom et chaîne du guide';

  @override
  String get reasonSameNameNumber => 'même nom avec numéro';

  @override
  String get reasonSameName => 'même nom';

  @override
  String get reasonNumberedFamily => 'famille numérotée';

  @override
  String get versionDefault => 'Standard';

  @override
  String get options => 'Options';

  @override
  String get hide => 'Masquer';

  @override
  String get unhide => 'Réafficher';

  @override
  String get regroupVersions => 'Regrouper les versions';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get favorited => 'Favori';

  @override
  String get chooseVersion => 'Choisir la version';

  @override
  String get yourPreference => '(votre préférence)';

  @override
  String get automatic => '(automatique)';

  @override
  String get separateGroup => 'Séparer ce groupe';

  @override
  String get removeFromRecent => 'Retirer des récents';

  @override
  String get watch => 'Regarder';

  @override
  String get versions => 'Versions';

  @override
  String directedBy(String names) {
    return 'Réalisation : $names';
  }

  @override
  String castList(String names) {
    return 'Distribution : $names';
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
    return 'Épisode $number';
  }

  @override
  String get specials => 'Épisodes spéciaux';

  @override
  String seasonN(int number) {
    return 'Saison $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons saison(s) · $episodes épisode(s)';
  }

  @override
  String get previousEpisodes => 'Épisodes précédents';

  @override
  String get nextEpisodes => 'Épisodes suivants';

  @override
  String pageOf(int page, int pages) {
    return 'Page $page sur $pages';
  }

  @override
  String get lastWatched => 'Dernier';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Épisode suivant dans $seconds s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'S$season E$episode';
  }

  @override
  String get back15 => 'Reculer de 15 s';

  @override
  String get forward15 => 'Avancer de 15 s';

  @override
  String get previousEpisode => 'Épisode précédent';

  @override
  String get nextEpisode => 'Épisode suivant';

  @override
  String get mute => 'Couper le son';

  @override
  String get unmute => 'Activer le son';

  @override
  String liveStalledReconnecting(String name) {
    return '« $name » s\'est figée. Reconnexion...';
  }

  @override
  String liveNotBack(String name) {
    return '« $name » n\'est pas revenue. Réessayez dans un instant.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from s\'est figée. Passage à $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'Aucune version de « $name » n\'a pu s\'ouvrir.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'La version $version ne s\'est pas ouverte. Essai de $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'La version $version ne s\'est pas ouverte';
  }

  @override
  String tryAnotherVersion(String name) {
    return 'Essayer une autre version de « $name » ?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'Impossible de télécharger la liste ($error). J\'utilise la liste précédente.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb Mo téléchargés';
  }

  @override
  String mbOf(String received, String total) {
    return '$received sur $total Mo';
  }

  @override
  String get queued => 'En attente...';

  @override
  String get connecting => 'Connexion au serveur...';

  @override
  String get preparingList => 'Préparation de la nouvelle liste...';

  @override
  String get listUpdatedAuto => 'Liste mise à jour automatiquement.';

  @override
  String get listUpdated => 'Liste mise à jour.';

  @override
  String listUpdateFailed(String error) {
    return 'Impossible de mettre à jour la liste ($error). Je garde la précédente.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'Impossible de mettre à jour la liste ($error). Je garde la précédente ; nouvel essai dans une heure.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Mise à jour de la liste : $progress (vous pouvez continuer)';
  }

  @override
  String get updatingList => 'Mise à jour de la liste...';

  @override
  String get refreshListBackground =>
      'Mettre à jour la liste (en arrière-plan)';

  @override
  String get firstDownload =>
      'Téléchargement et préparation de la liste (lent seulement la première fois)...';

  @override
  String get metaNoServer =>
      'Impossible d\'identifier le serveur de la liste pour obtenir notes et dates.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Notes chargées : $rated sur $movies films, $ratedSeries sur $series séries.';
  }

  @override
  String metaError(String error) {
    return 'Notes et dates : $error';
  }

  @override
  String sortBy(String mode) {
    return 'Trier : $mode';
  }

  @override
  String get sortListOrder => 'Ordre de la liste';

  @override
  String get sortListOrderReverse => 'Ordre de la liste (inversé)';

  @override
  String get sortRecent => 'Ajoutés récemment';

  @override
  String get sortRecentSeries => 'Ajoutées ou mises à jour récemment';

  @override
  String get sortRating => 'Mieux notés';

  @override
  String get sortYear => 'Année (plus récent)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (chargement...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (indisponible)';
  }

  @override
  String get profiles => 'Profils';

  @override
  String get newProfileMenu => 'Nouveau profil...';

  @override
  String get editProfileMenu => 'Modifier le profil actuel...';

  @override
  String get deleteProfileMenu => 'Supprimer le profil actuel';

  @override
  String get createProfile => 'Créer un profil';

  @override
  String deleteProfileTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteProfileBody =>
      'La liste téléchargée, le guide et les éléments masqués de ce profil seront aussi supprimés.';

  @override
  String get newProfile => 'Nouveau profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get userName => 'Nom de l\'utilisateur';

  @override
  String get playlistField => 'Liste M3U (URL ou chemin du fichier)';

  @override
  String get guideField =>
      'Guide XMLTV (facultatif ; vide = détection automatique)';

  @override
  String get fillNameAndPlaylist => 'Renseignez le nom et la liste.';

  @override
  String get playlistUrlHint =>
      'Utilisez une URL http(s) ou le chemin d\'un fichier.';

  @override
  String get guideUrlHint =>
      'Guide : utilisez une URL http(s) ou un fichier XMLTV.';

  @override
  String get acceptInvalidCert =>
      'Accepter le certificat invalide de ce serveur';

  @override
  String get acceptInvalidCertHint =>
      'Seulement pour les listes de confiance. Décoché est plus sûr.';

  @override
  String get autoRefreshList => 'Mettre à jour la liste automatiquement';

  @override
  String get refresh6h => 'Toutes les 6 heures';

  @override
  String get refresh12h => 'Toutes les 12 heures';

  @override
  String get refresh24h => 'Toutes les 24 heures';

  @override
  String get refresh24hDefault => 'Toutes les 24 heures (par défaut)';

  @override
  String get refresh2d => 'Tous les 2 jours';

  @override
  String get refreshWeekly => 'Une fois par semaine';

  @override
  String get refreshNever => 'Jamais (seulement à la demande)';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeNavy => 'Bleu';

  @override
  String get themeBlack => 'Noir';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get accentGold => 'Doré';

  @override
  String get accentBlue => 'Bleu';

  @override
  String get accentGreen => 'Vert';

  @override
  String get accentRed => 'Rouge';

  @override
  String get accentPurple => 'Violet';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get listSection => 'Liste';

  @override
  String get refreshListNow => 'Mettre à jour la liste maintenant';

  @override
  String get refreshGuideNow => 'Mettre à jour le guide maintenant';

  @override
  String get repeatedVersions => 'Versions répétées';

  @override
  String get display => 'Affichage';

  @override
  String get showHidden => 'Afficher les éléments masqués';

  @override
  String get perfMonitor => 'Moniteur de performances (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Panneau sur la vidéo et historique dans desempenho.csv';

  @override
  String get profileSection => 'Profil';

  @override
  String get editCurrentProfile => 'Modifier le profil actuel';

  @override
  String perfLogAt(String path) {
    return 'Enregistrement de l\'historique dans $path';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Interface  $fps FPS · $slow lentes · pire $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Vidéo      $fps sur $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Pertes     $rate/s · $count en 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Tampon     $seconds s';
  }

  @override
  String get perfLoadingTag => ' · CHARGEMENT';

  @override
  String get perfLegend =>
      'blanc : interface · bleu : vidéo · rouge : chargement';

  @override
  String get errCertHint =>
      'Si vous faites confiance à ce serveur, cochez « Accepter le certificat invalide de ce serveur » dans Modifier le profil.';

  @override
  String get errSelfSigned => 'le serveur utilise un certificat auto-signé.';

  @override
  String get errCertExpired =>
      'le certificat du serveur a expiré (ou la date de l\'ordinateur est fausse).';

  @override
  String get errCertHost =>
      'le certificat du serveur appartient à un autre domaine.';

  @override
  String get errCertUnknownCa =>
      'le certificat du serveur provient d\'une autorité inconnue.';

  @override
  String get errNoTls =>
      'le serveur n\'utilise pas TLS sur ce port ; essayez http:// au lieu de https://.';

  @override
  String get errTls => 'erreur TLS/certificat lors de la connexion';

  @override
  String get errInvalidUrl => 'URL invalide (utilisez http:// ou https://)';

  @override
  String get errNoResponse => 'le serveur ne répond plus';

  @override
  String get errDns =>
      'impossible de résoudre l\'adresse du serveur (DNS). Votre fournisseur la bloque peut-être, ou l\'adresse a changé.';

  @override
  String errConnection(String detail) {
    return 'échec de connexion ($detail)';
  }

  @override
  String get errNetwork => 'réseau';

  @override
  String get errIncomplete => 'le téléchargement est incomplet';

  @override
  String errBadHttp(String detail) {
    return 'réponse HTTP invalide : $detail';
  }

  @override
  String errForbidden(String status) {
    return 'le serveur a refusé l\'accès (HTTP $status). Vérifiez l\'identifiant et le mot de passe, ou si la liste a expiré.';
  }

  @override
  String get errEmpty => 'le serveur a renvoyé une réponse vide';

  @override
  String errHttp(int code) {
    return 'le serveur a répondu HTTP $code';
  }

  @override
  String get errTooSlow => 'le serveur envoie les données trop lentement';

  @override
  String errTooLong(int minutes) {
    return 'le téléchargement a dépassé $minutes min et a été annulé';
  }

  @override
  String get errGuideFileNotFound => 'fichier du guide introuvable';

  @override
  String get errGuideFormat => 'format du guide non reconnu';

  @override
  String get errNoGuideSource => 'aucune source de guide disponible';

  @override
  String get errServerResponse => 'réponse du serveur non reconnue';

  @override
  String get errNoMeta => 'le serveur n\'a renvoyé ni notes ni dates';
}
