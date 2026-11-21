// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get now => 'Now';

  @override
  String get tryAgain => 'Try again';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get favorites => 'Favorites';

  @override
  String get allCategories => 'All categories';

  @override
  String categoriesCount(int count) {
    return '$count categories';
  }

  @override
  String get searchCategory => 'Search categories';

  @override
  String categoriesOf(String section) {
    return 'Categories · $section';
  }

  @override
  String get liveChannels => 'Live channels';

  @override
  String get liveShort => 'Live';

  @override
  String get movies => 'Movies';

  @override
  String get series => 'Series';

  @override
  String get nothingHere => 'Nothing here';

  @override
  String get searchByName => 'Search by name';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get shrinkList => 'Shrink the list (large video)';

  @override
  String get expandList => 'Expand the list (small video)';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get programGuide => 'TV guide';

  @override
  String get channelOrProgram => 'Channel or program';

  @override
  String get oneHourBefore => 'One hour earlier';

  @override
  String get oneHourAfter => 'One hour later';

  @override
  String get guideNoChannels => 'No channel in this list has guide data.';

  @override
  String channelsCount(int count) {
    return '$count channels';
  }

  @override
  String get watchNow => 'Watch now';

  @override
  String get openChannel => 'Open channel';

  @override
  String get guideNotFound =>
      'Couldn\'t find a TV guide (EPG) in the list or on its server.';

  @override
  String get guideDeferred => 'Guide: update postponed until the video stops';

  @override
  String get guideDownloading => 'Downloading the TV guide...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Guide: $programmes programs, $channels channels with listings';
  }

  @override
  String guideError(String error) {
    return 'Guide: $error';
  }

  @override
  String get groupRepeatedVersions => 'Group repeated versions';

  @override
  String get groupingSubtitle =>
      'HD, FHD, 4K, dubbed, subtitled... in a single card';

  @override
  String get reviewGroups => 'Review groups';

  @override
  String get reviewGroupsMenu => 'Review groups…';

  @override
  String separatedGroups(int count) {
    return 'Split groups ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Split groups ($count)…';
  }

  @override
  String get noSeparatedGroups => 'No split groups.';

  @override
  String get regroup => 'Regroup';

  @override
  String get regroupAll => 'Regroup all';

  @override
  String get separate => 'Split';

  @override
  String get allRegrouped => 'All groups were merged again.';

  @override
  String groupSeparated(String name) {
    return 'Group \"$name\" split. Its versions now show separately.';
  }

  @override
  String get versionsRegrouped => 'Versions merged again.';

  @override
  String versionsOfRegrouped(String name) {
    return 'The versions of \"$name\" were merged again.';
  }

  @override
  String get preferredForgotten => 'Preferred versions were forgotten.';

  @override
  String get forgetPreferred => 'Forget preferred versions';

  @override
  String reviewIntro(int count) {
    return '$count groups were merged by name and image only. Those merged by name alone come first. Split anything that isn\'t the same thing.';
  }

  @override
  String get searchGroup => 'Search groups';

  @override
  String get nothingToReview => 'Nothing to review here.';

  @override
  String get reasonSameTvgId => 'same tvg-id';

  @override
  String get reasonSameTmdb => 'same TMDB';

  @override
  String get reasonSameNameYear => 'same name and year';

  @override
  String get reasonSameNameImage => 'same name and image';

  @override
  String get reasonSameNameGuide => 'same name and guide channel';

  @override
  String get reasonSameNameNumber => 'same name with number';

  @override
  String get reasonSameName => 'same name';

  @override
  String get reasonNumberedFamily => 'numbered family';

  @override
  String get versionDefault => 'Default';

  @override
  String get options => 'Options';

  @override
  String get hide => 'Hide';

  @override
  String get unhide => 'Unhide';

  @override
  String get regroupVersions => 'Merge the versions again';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get favorited => 'Favorite';

  @override
  String get chooseVersion => 'Choose version';

  @override
  String get yourPreference => '(your preference)';

  @override
  String get automatic => '(automatic)';

  @override
  String get separateGroup => 'Split this group';

  @override
  String get removeFromRecent => 'Remove from recent';

  @override
  String get watch => 'Watch';

  @override
  String get versions => 'Versions';

  @override
  String directedBy(String names) {
    return 'Director: $names';
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
    return 'Episode $number';
  }

  @override
  String get specials => 'Specials';

  @override
  String seasonN(int number) {
    return 'Season $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons season(s) · $episodes episode(s)';
  }

  @override
  String get previousEpisodes => 'Previous episodes';

  @override
  String get nextEpisodes => 'Next episodes';

  @override
  String pageOf(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get lastWatched => 'Last';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Next episode in ${seconds}s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'S$season E$episode';
  }

  @override
  String get back15 => 'Back 15 s';

  @override
  String get forward15 => 'Forward 15 s';

  @override
  String get previousEpisode => 'Previous episode';

  @override
  String get nextEpisode => 'Next episode';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String liveStalledReconnecting(String name) {
    return '\"$name\" froze. Reconnecting...';
  }

  @override
  String liveNotBack(String name) {
    return '\"$name\" didn\'t come back. Try again in a moment.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from froze. Switching to $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'No version of \"$name\" opened right now.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'Version $version didn\'t open. Trying $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'Version $version didn\'t open';
  }

  @override
  String tryAnotherVersion(String name) {
    return 'Try another version of \"$name\"?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'Couldn\'t download the list ($error). Using the previous list.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb MB downloaded';
  }

  @override
  String mbOf(String received, String total) {
    return '$received of $total MB';
  }

  @override
  String get queued => 'Queued...';

  @override
  String get connecting => 'Connecting to the server...';

  @override
  String get preparingList => 'Preparing the new list...';

  @override
  String get listUpdatedAuto => 'List updated automatically.';

  @override
  String get listUpdated => 'List updated.';

  @override
  String listUpdateFailed(String error) {
    return 'Couldn\'t update the list ($error). Keeping the previous one.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'Couldn\'t update the list ($error). Keeping the previous one; I\'ll try again in an hour.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Updating the list: $progress (you can keep using the app)';
  }

  @override
  String get updatingList => 'Updating the list...';

  @override
  String get refreshListBackground => 'Update the list (in the background)';

  @override
  String get firstDownload =>
      'Downloading and preparing the list (only slow the first time)...';

  @override
  String get metaNoServer =>
      'Couldn\'t identify the list\'s server to fetch ratings and dates.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Ratings loaded: $rated of $movies movies, $ratedSeries of $series series.';
  }

  @override
  String metaError(String error) {
    return 'Ratings and dates: $error';
  }

  @override
  String sortBy(String mode) {
    return 'Sort: $mode';
  }

  @override
  String get sortListOrder => 'List order';

  @override
  String get sortListOrderReverse => 'List order (reversed)';

  @override
  String get sortRecent => 'Recently added';

  @override
  String get sortRecentSeries => 'Recently added or updated';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortYear => 'Year (newest)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (loading...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (unavailable)';
  }

  @override
  String get profiles => 'Profiles';

  @override
  String get newProfileMenu => 'New profile...';

  @override
  String get editProfileMenu => 'Edit current profile...';

  @override
  String get deleteProfileMenu => 'Delete current profile';

  @override
  String get createProfile => 'Create profile';

  @override
  String deleteProfileTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteProfileBody =>
      'This profile\'s downloaded list, guide and hidden items will also be deleted.';

  @override
  String get newProfile => 'New profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get userName => 'User name';

  @override
  String get playlistField => 'M3U playlist (URL or file path)';

  @override
  String get guideField =>
      'XMLTV guide (optional; empty = detect automatically)';

  @override
  String get fillNameAndPlaylist => 'Fill in the name and the playlist.';

  @override
  String get playlistUrlHint => 'Use an http(s) URL or a file path.';

  @override
  String get guideUrlHint => 'Guide: use an http(s) URL or an XMLTV file.';

  @override
  String get acceptInvalidCert => 'Accept this server\'s invalid certificate';

  @override
  String get acceptInvalidCertHint =>
      'Only for lists you trust. Unchecked is safer.';

  @override
  String get autoRefreshList => 'Update the list automatically';

  @override
  String get refresh6h => 'Every 6 hours';

  @override
  String get refresh12h => 'Every 12 hours';

  @override
  String get refresh24h => 'Every 24 hours';

  @override
  String get refresh24hDefault => 'Every 24 hours (default)';

  @override
  String get refresh2d => 'Every 2 days';

  @override
  String get refreshWeekly => 'Once a week';

  @override
  String get refreshNever => 'Never (only when I ask)';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeNavy => 'Navy';

  @override
  String get themeBlack => 'Black';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get accentGold => 'Gold';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentRed => 'Red';

  @override
  String get accentPurple => 'Purple';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get listSection => 'List';

  @override
  String get refreshListNow => 'Update the list now';

  @override
  String get refreshGuideNow => 'Update the guide now';

  @override
  String get repeatedVersions => 'Repeated versions';

  @override
  String get display => 'Display';

  @override
  String get showHidden => 'Show hidden items';

  @override
  String get perfMonitor => 'Performance monitor (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Panel over the video and history in desempenho.csv';

  @override
  String get profileSection => 'Profile';

  @override
  String get editCurrentProfile => 'Edit current profile';

  @override
  String perfLogAt(String path) {
    return 'Recording history to $path';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Interface  $fps FPS · $slow slow · worst $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Video      $fps of $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Drops      $rate/s · $count in 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Buffer     $seconds s';
  }

  @override
  String get perfLoadingTag => ' · LOADING';

  @override
  String get perfLegend => 'white: interface · blue: video · red: loading';

  @override
  String get errCertHint =>
      'If you trust this server, check \"Accept this server\'s invalid certificate\" in Edit profile.';

  @override
  String get errSelfSigned => 'the server uses a self-signed certificate.';

  @override
  String get errCertExpired =>
      'the server\'s certificate has expired (or the computer\'s date is wrong).';

  @override
  String get errCertHost =>
      'the server\'s certificate belongs to another domain.';

  @override
  String get errCertUnknownCa =>
      'the server\'s certificate comes from an unknown authority.';

  @override
  String get errNoTls =>
      'the server doesn\'t speak TLS on this port; try http:// instead of https://.';

  @override
  String get errTls => 'TLS/certificate error while connecting';

  @override
  String get errInvalidUrl => 'invalid URL (use http:// or https://)';

  @override
  String get errNoResponse => 'the server stopped responding';

  @override
  String get errDns =>
      'couldn\'t resolve the server\'s address (DNS). Your provider may be blocking it, or the address changed.';

  @override
  String errConnection(String detail) {
    return 'connection failed ($detail)';
  }

  @override
  String get errNetwork => 'network';

  @override
  String get errIncomplete => 'the download arrived incomplete';

  @override
  String errBadHttp(String detail) {
    return 'invalid HTTP response: $detail';
  }

  @override
  String errForbidden(String status) {
    return 'the server refused access (HTTP $status). Check the user name and password, or whether the list has expired.';
  }

  @override
  String get errEmpty => 'the server returned an empty response';

  @override
  String errHttp(int code) {
    return 'the server answered HTTP $code';
  }

  @override
  String get errTooSlow => 'the server is sending data too slowly';

  @override
  String errTooLong(int minutes) {
    return 'the download took more than $minutes min and was cancelled';
  }

  @override
  String get errGuideFileNotFound => 'guide file not found';

  @override
  String get errGuideFormat => 'guide format not recognized';

  @override
  String get errNoGuideSource => 'no guide source available';

  @override
  String get errServerResponse => 'unrecognized server response';

  @override
  String get errNoMeta => 'the server returned no ratings or dates';
}
