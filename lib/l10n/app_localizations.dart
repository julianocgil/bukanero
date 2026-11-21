import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @now.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get now;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @errorPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Erro: {error}'**
  String errorPrefix(String error);

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @favorites.
  ///
  /// In pt, this message translates to:
  /// **'Favoritos'**
  String get favorites;

  /// No description provided for @allCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas as categorias'**
  String get allCategories;

  /// No description provided for @categoriesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} categorias'**
  String categoriesCount(int count);

  /// No description provided for @searchCategory.
  ///
  /// In pt, this message translates to:
  /// **'Procurar categoria'**
  String get searchCategory;

  /// No description provided for @categoriesOf.
  ///
  /// In pt, this message translates to:
  /// **'Categorias · {section}'**
  String categoriesOf(String section);

  /// No description provided for @liveChannels.
  ///
  /// In pt, this message translates to:
  /// **'Canais ao vivo'**
  String get liveChannels;

  /// No description provided for @liveShort.
  ///
  /// In pt, this message translates to:
  /// **'Ao vivo'**
  String get liveShort;

  /// No description provided for @movies.
  ///
  /// In pt, this message translates to:
  /// **'Filmes'**
  String get movies;

  /// No description provided for @series.
  ///
  /// In pt, this message translates to:
  /// **'Séries'**
  String get series;

  /// No description provided for @nothingHere.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui'**
  String get nothingHere;

  /// No description provided for @searchByName.
  ///
  /// In pt, this message translates to:
  /// **'Buscar pelo nome'**
  String get searchByName;

  /// No description provided for @clearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar a busca'**
  String get clearSearch;

  /// No description provided for @shrinkList.
  ///
  /// In pt, this message translates to:
  /// **'Reduzir a lista (vídeo grande)'**
  String get shrinkList;

  /// No description provided for @expandList.
  ///
  /// In pt, this message translates to:
  /// **'Ampliar a lista (vídeo pequeno)'**
  String get expandList;

  /// No description provided for @continueWatching.
  ///
  /// In pt, this message translates to:
  /// **'Continuar assistindo'**
  String get continueWatching;

  /// No description provided for @programGuide.
  ///
  /// In pt, this message translates to:
  /// **'Guia de programação'**
  String get programGuide;

  /// No description provided for @channelOrProgram.
  ///
  /// In pt, this message translates to:
  /// **'Canal ou programa'**
  String get channelOrProgram;

  /// No description provided for @oneHourBefore.
  ///
  /// In pt, this message translates to:
  /// **'Uma hora antes'**
  String get oneHourBefore;

  /// No description provided for @oneHourAfter.
  ///
  /// In pt, this message translates to:
  /// **'Uma hora depois'**
  String get oneHourAfter;

  /// No description provided for @guideNoChannels.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum canal desta lista tem programação no guia.'**
  String get guideNoChannels;

  /// No description provided for @channelsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} canais'**
  String channelsCount(int count);

  /// No description provided for @watchNow.
  ///
  /// In pt, this message translates to:
  /// **'Assistir agora'**
  String get watchNow;

  /// No description provided for @openChannel.
  ///
  /// In pt, this message translates to:
  /// **'Abrir o canal'**
  String get openChannel;

  /// No description provided for @guideNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não achei o guia (EPG) nem na lista nem no servidor dela.'**
  String get guideNotFound;

  /// No description provided for @guideDeferred.
  ///
  /// In pt, this message translates to:
  /// **'Guia: atualização adiada até o vídeo parar'**
  String get guideDeferred;

  /// No description provided for @guideDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando o guia de programação...'**
  String get guideDownloading;

  /// No description provided for @guideStatus.
  ///
  /// In pt, this message translates to:
  /// **'Guia: {programmes} programas, {channels} canais com programação'**
  String guideStatus(int programmes, int channels);

  /// No description provided for @guideError.
  ///
  /// In pt, this message translates to:
  /// **'Guia: {error}'**
  String guideError(String error);

  /// No description provided for @groupRepeatedVersions.
  ///
  /// In pt, this message translates to:
  /// **'Agrupar versões repetidas'**
  String get groupRepeatedVersions;

  /// No description provided for @groupingSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'HD, FHD, 4K, dublado, legendado... num cartão só'**
  String get groupingSubtitle;

  /// No description provided for @reviewGroups.
  ///
  /// In pt, this message translates to:
  /// **'Revisar agrupamentos'**
  String get reviewGroups;

  /// No description provided for @reviewGroupsMenu.
  ///
  /// In pt, this message translates to:
  /// **'Revisar agrupamentos…'**
  String get reviewGroupsMenu;

  /// No description provided for @separatedGroups.
  ///
  /// In pt, this message translates to:
  /// **'Grupos separados ({count})'**
  String separatedGroups(int count);

  /// No description provided for @separatedGroupsMenu.
  ///
  /// In pt, this message translates to:
  /// **'Grupos separados ({count})…'**
  String separatedGroupsMenu(int count);

  /// No description provided for @noSeparatedGroups.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum grupo separado.'**
  String get noSeparatedGroups;

  /// No description provided for @regroup.
  ///
  /// In pt, this message translates to:
  /// **'Reagrupar'**
  String get regroup;

  /// No description provided for @regroupAll.
  ///
  /// In pt, this message translates to:
  /// **'Reagrupar todos'**
  String get regroupAll;

  /// No description provided for @separate.
  ///
  /// In pt, this message translates to:
  /// **'Separar'**
  String get separate;

  /// No description provided for @allRegrouped.
  ///
  /// In pt, this message translates to:
  /// **'Todos os grupos foram juntados de novo.'**
  String get allRegrouped;

  /// No description provided for @groupSeparated.
  ///
  /// In pt, this message translates to:
  /// **'Grupo \"{name}\" separado. As versões aparecem soltas.'**
  String groupSeparated(String name);

  /// No description provided for @versionsRegrouped.
  ///
  /// In pt, this message translates to:
  /// **'Versões juntadas de novo.'**
  String get versionsRegrouped;

  /// No description provided for @versionsOfRegrouped.
  ///
  /// In pt, this message translates to:
  /// **'As versões de \"{name}\" foram juntadas de novo.'**
  String versionsOfRegrouped(String name);

  /// No description provided for @preferredForgotten.
  ///
  /// In pt, this message translates to:
  /// **'As versões preferidas foram esquecidas.'**
  String get preferredForgotten;

  /// No description provided for @forgetPreferred.
  ///
  /// In pt, this message translates to:
  /// **'Esquecer versões preferidas'**
  String get forgetPreferred;

  /// No description provided for @reviewIntro.
  ///
  /// In pt, this message translates to:
  /// **'{count} grupos foram juntados só por nome e imagem. Os juntados só pelo nome vêm primeiro. Separe o que não for a mesma coisa.'**
  String reviewIntro(int count);

  /// No description provided for @searchGroup.
  ///
  /// In pt, this message translates to:
  /// **'Procurar grupo'**
  String get searchGroup;

  /// No description provided for @nothingToReview.
  ///
  /// In pt, this message translates to:
  /// **'Nada para revisar aqui.'**
  String get nothingToReview;

  /// No description provided for @reasonSameTvgId.
  ///
  /// In pt, this message translates to:
  /// **'mesmo tvg-id'**
  String get reasonSameTvgId;

  /// No description provided for @reasonSameTmdb.
  ///
  /// In pt, this message translates to:
  /// **'mesmo TMDB'**
  String get reasonSameTmdb;

  /// No description provided for @reasonSameNameYear.
  ///
  /// In pt, this message translates to:
  /// **'mesmo nome e ano'**
  String get reasonSameNameYear;

  /// No description provided for @reasonSameNameImage.
  ///
  /// In pt, this message translates to:
  /// **'mesmo nome e imagem'**
  String get reasonSameNameImage;

  /// No description provided for @reasonSameNameGuide.
  ///
  /// In pt, this message translates to:
  /// **'mesmo nome e canal do guia'**
  String get reasonSameNameGuide;

  /// No description provided for @reasonSameNameNumber.
  ///
  /// In pt, this message translates to:
  /// **'mesmo nome com número'**
  String get reasonSameNameNumber;

  /// No description provided for @reasonSameName.
  ///
  /// In pt, this message translates to:
  /// **'mesmo nome'**
  String get reasonSameName;

  /// No description provided for @reasonNumberedFamily.
  ///
  /// In pt, this message translates to:
  /// **'família numerada'**
  String get reasonNumberedFamily;

  /// No description provided for @versionDefault.
  ///
  /// In pt, this message translates to:
  /// **'Padrão'**
  String get versionDefault;

  /// No description provided for @options.
  ///
  /// In pt, this message translates to:
  /// **'Opções'**
  String get options;

  /// No description provided for @hide.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar'**
  String get hide;

  /// No description provided for @unhide.
  ///
  /// In pt, this message translates to:
  /// **'Reexibir'**
  String get unhide;

  /// No description provided for @regroupVersions.
  ///
  /// In pt, this message translates to:
  /// **'Juntar as versões de novo'**
  String get regroupVersions;

  /// No description provided for @addFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Favoritar'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In pt, this message translates to:
  /// **'Tirar dos favoritos'**
  String get removeFavorite;

  /// No description provided for @favorited.
  ///
  /// In pt, this message translates to:
  /// **'Favorito'**
  String get favorited;

  /// No description provided for @chooseVersion.
  ///
  /// In pt, this message translates to:
  /// **'Escolher a versão'**
  String get chooseVersion;

  /// No description provided for @yourPreference.
  ///
  /// In pt, this message translates to:
  /// **'(sua preferência)'**
  String get yourPreference;

  /// No description provided for @automatic.
  ///
  /// In pt, this message translates to:
  /// **'(automática)'**
  String get automatic;

  /// No description provided for @separateGroup.
  ///
  /// In pt, this message translates to:
  /// **'Separar este grupo'**
  String get separateGroup;

  /// No description provided for @removeFromRecent.
  ///
  /// In pt, this message translates to:
  /// **'Tirar dos recentes'**
  String get removeFromRecent;

  /// No description provided for @watch.
  ///
  /// In pt, this message translates to:
  /// **'Assistir'**
  String get watch;

  /// No description provided for @versions.
  ///
  /// In pt, this message translates to:
  /// **'Versões'**
  String get versions;

  /// No description provided for @directedBy.
  ///
  /// In pt, this message translates to:
  /// **'Direção: {names}'**
  String directedBy(String names);

  /// No description provided for @castList.
  ///
  /// In pt, this message translates to:
  /// **'Elenco: {names}'**
  String castList(String names);

  /// No description provided for @durationHours.
  ///
  /// In pt, this message translates to:
  /// **'{hours} h {minutes}'**
  String durationHours(int hours, String minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @episodeN.
  ///
  /// In pt, this message translates to:
  /// **'Episódio {number}'**
  String episodeN(int number);

  /// No description provided for @specials.
  ///
  /// In pt, this message translates to:
  /// **'Especiais'**
  String get specials;

  /// No description provided for @seasonN.
  ///
  /// In pt, this message translates to:
  /// **'Temporada {number}'**
  String seasonN(int number);

  /// No description provided for @seasonsEpisodes.
  ///
  /// In pt, this message translates to:
  /// **'{seasons} temporada(s) · {episodes} episódio(s)'**
  String seasonsEpisodes(int seasons, int episodes);

  /// No description provided for @previousEpisodes.
  ///
  /// In pt, this message translates to:
  /// **'Episódios anteriores'**
  String get previousEpisodes;

  /// No description provided for @nextEpisodes.
  ///
  /// In pt, this message translates to:
  /// **'Próximos episódios'**
  String get nextEpisodes;

  /// No description provided for @pageOf.
  ///
  /// In pt, this message translates to:
  /// **'Página {page} de {pages}'**
  String pageOf(int page, int pages);

  /// No description provided for @lastWatched.
  ///
  /// In pt, this message translates to:
  /// **'Último'**
  String get lastWatched;

  /// No description provided for @nextEpisodeIn.
  ///
  /// In pt, this message translates to:
  /// **'Próximo episódio em {seconds}s'**
  String nextEpisodeIn(int seconds);

  /// No description provided for @seasonEpisodeShort.
  ///
  /// In pt, this message translates to:
  /// **'T{season} E{episode}'**
  String seasonEpisodeShort(String season, String episode);

  /// No description provided for @back15.
  ///
  /// In pt, this message translates to:
  /// **'Voltar 15 s'**
  String get back15;

  /// No description provided for @forward15.
  ///
  /// In pt, this message translates to:
  /// **'Avançar 15 s'**
  String get forward15;

  /// No description provided for @previousEpisode.
  ///
  /// In pt, this message translates to:
  /// **'Episódio anterior'**
  String get previousEpisode;

  /// No description provided for @nextEpisode.
  ///
  /// In pt, this message translates to:
  /// **'Próximo episódio'**
  String get nextEpisode;

  /// No description provided for @mute.
  ///
  /// In pt, this message translates to:
  /// **'Tirar o som'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In pt, this message translates to:
  /// **'Ligar o som'**
  String get unmute;

  /// No description provided for @liveStalledReconnecting.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\" travou. Reconectando...'**
  String liveStalledReconnecting(String name);

  /// No description provided for @liveNotBack.
  ///
  /// In pt, this message translates to:
  /// **'\"{name}\" não voltou. Tente de novo daqui a pouco.'**
  String liveNotBack(String name);

  /// No description provided for @liveSwitching.
  ///
  /// In pt, this message translates to:
  /// **'{from} travou. Mudando para {to}...'**
  String liveSwitching(String from, String to);

  /// No description provided for @noVersionOpened.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma versão de \"{name}\" abriu agora.'**
  String noVersionOpened(String name);

  /// No description provided for @versionFailedTrying.
  ///
  /// In pt, this message translates to:
  /// **'A versão {version} não abriu. Tentando {next}...'**
  String versionFailedTrying(String version, String next);

  /// No description provided for @versionFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'A versão {version} não abriu'**
  String versionFailedTitle(String version);

  /// No description provided for @tryAnotherVersion.
  ///
  /// In pt, this message translates to:
  /// **'Quer tentar outra versão de \"{name}\"?'**
  String tryAnotherVersion(String name);

  /// No description provided for @listDownloadFailedUsingOld.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui baixar a lista ({error}). Usando a lista anterior.'**
  String listDownloadFailedUsingOld(String error);

  /// No description provided for @mbDownloaded.
  ///
  /// In pt, this message translates to:
  /// **'{mb} MB baixados'**
  String mbDownloaded(String mb);

  /// No description provided for @mbOf.
  ///
  /// In pt, this message translates to:
  /// **'{received} de {total} MB'**
  String mbOf(String received, String total);

  /// No description provided for @queued.
  ///
  /// In pt, this message translates to:
  /// **'Na fila...'**
  String get queued;

  /// No description provided for @connecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando ao servidor...'**
  String get connecting;

  /// No description provided for @preparingList.
  ///
  /// In pt, this message translates to:
  /// **'Preparando a lista nova...'**
  String get preparingList;

  /// No description provided for @listUpdatedAuto.
  ///
  /// In pt, this message translates to:
  /// **'Lista atualizada automaticamente.'**
  String get listUpdatedAuto;

  /// No description provided for @listUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Lista atualizada.'**
  String get listUpdated;

  /// No description provided for @listUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui atualizar a lista ({error}). Continuo com a anterior.'**
  String listUpdateFailed(String error);

  /// No description provided for @listUpdateFailedRetry.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui atualizar a lista ({error}). Continuo com a anterior; tento de novo daqui a uma hora.'**
  String listUpdateFailedRetry(String error);

  /// No description provided for @updatingListProgress.
  ///
  /// In pt, this message translates to:
  /// **'Atualizando a lista: {progress} (pode continuar usando)'**
  String updatingListProgress(String progress);

  /// No description provided for @updatingList.
  ///
  /// In pt, this message translates to:
  /// **'Atualizando a lista...'**
  String get updatingList;

  /// No description provided for @refreshListBackground.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar a lista (em segundo plano)'**
  String get refreshListBackground;

  /// No description provided for @firstDownload.
  ///
  /// In pt, this message translates to:
  /// **'Baixando e preparando a lista (só demora na primeira vez)...'**
  String get firstDownload;

  /// No description provided for @metaNoServer.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui identificar o servidor da lista para buscar notas e datas.'**
  String get metaNoServer;

  /// No description provided for @metaLoaded.
  ///
  /// In pt, this message translates to:
  /// **'Notas carregadas: {rated} de {movies} filmes, {ratedSeries} de {series} séries.'**
  String metaLoaded(int rated, int movies, int ratedSeries, int series);

  /// No description provided for @metaError.
  ///
  /// In pt, this message translates to:
  /// **'Notas e datas: {error}'**
  String metaError(String error);

  /// No description provided for @sortBy.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar: {mode}'**
  String sortBy(String mode);

  /// No description provided for @sortListOrder.
  ///
  /// In pt, this message translates to:
  /// **'Ordem da lista'**
  String get sortListOrder;

  /// No description provided for @sortListOrderReverse.
  ///
  /// In pt, this message translates to:
  /// **'Ordem da lista (invertida)'**
  String get sortListOrderReverse;

  /// No description provided for @sortRecent.
  ///
  /// In pt, this message translates to:
  /// **'Adicionados recentemente'**
  String get sortRecent;

  /// No description provided for @sortRecentSeries.
  ///
  /// In pt, this message translates to:
  /// **'Adicionadas ou atualizadas recentemente'**
  String get sortRecentSeries;

  /// No description provided for @sortRating.
  ///
  /// In pt, this message translates to:
  /// **'Melhor nota'**
  String get sortRating;

  /// No description provided for @sortYear.
  ///
  /// In pt, this message translates to:
  /// **'Ano (mais novo)'**
  String get sortYear;

  /// No description provided for @sortModeLoading.
  ///
  /// In pt, this message translates to:
  /// **'{mode} (carregando...)'**
  String sortModeLoading(String mode);

  /// No description provided for @sortModeUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'{mode} (indisponível)'**
  String sortModeUnavailable(String mode);

  /// No description provided for @profiles.
  ///
  /// In pt, this message translates to:
  /// **'Perfis'**
  String get profiles;

  /// No description provided for @newProfileMenu.
  ///
  /// In pt, this message translates to:
  /// **'Novo perfil...'**
  String get newProfileMenu;

  /// No description provided for @editProfileMenu.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil atual...'**
  String get editProfileMenu;

  /// No description provided for @deleteProfileMenu.
  ///
  /// In pt, this message translates to:
  /// **'Excluir perfil atual'**
  String get deleteProfileMenu;

  /// No description provided for @createProfile.
  ///
  /// In pt, this message translates to:
  /// **'Criar perfil'**
  String get createProfile;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir \"{name}\"?'**
  String deleteProfileTitle(String name);

  /// No description provided for @deleteProfileBody.
  ///
  /// In pt, this message translates to:
  /// **'A lista baixada, o guia e os itens ocultos deste perfil também serão apagados.'**
  String get deleteProfileBody;

  /// No description provided for @newProfile.
  ///
  /// In pt, this message translates to:
  /// **'Novo perfil'**
  String get newProfile;

  /// No description provided for @editProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @userName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do usuário'**
  String get userName;

  /// No description provided for @playlistField.
  ///
  /// In pt, this message translates to:
  /// **'Playlist M3U (URL ou caminho do arquivo)'**
  String get playlistField;

  /// No description provided for @guideField.
  ///
  /// In pt, this message translates to:
  /// **'Guia XMLTV (opcional; vazio = detectar sozinho)'**
  String get guideField;

  /// No description provided for @fillNameAndPlaylist.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o nome e a playlist.'**
  String get fillNameAndPlaylist;

  /// No description provided for @playlistUrlHint.
  ///
  /// In pt, this message translates to:
  /// **'Use uma URL http(s) ou o caminho de um arquivo.'**
  String get playlistUrlHint;

  /// No description provided for @guideUrlHint.
  ///
  /// In pt, this message translates to:
  /// **'Guia: use uma URL http(s) ou um arquivo XMLTV.'**
  String get guideUrlHint;

  /// No description provided for @acceptInvalidCert.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar o certificado inválido deste servidor'**
  String get acceptInvalidCert;

  /// No description provided for @acceptInvalidCertHint.
  ///
  /// In pt, this message translates to:
  /// **'Só para listas em que você confia. Desmarcado é mais seguro.'**
  String get acceptInvalidCertHint;

  /// No description provided for @autoRefreshList.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar a lista sozinho'**
  String get autoRefreshList;

  /// No description provided for @refresh6h.
  ///
  /// In pt, this message translates to:
  /// **'A cada 6 horas'**
  String get refresh6h;

  /// No description provided for @refresh12h.
  ///
  /// In pt, this message translates to:
  /// **'A cada 12 horas'**
  String get refresh12h;

  /// No description provided for @refresh24h.
  ///
  /// In pt, this message translates to:
  /// **'A cada 24 horas'**
  String get refresh24h;

  /// No description provided for @refresh24hDefault.
  ///
  /// In pt, this message translates to:
  /// **'A cada 24 horas (padrão)'**
  String get refresh24hDefault;

  /// No description provided for @refresh2d.
  ///
  /// In pt, this message translates to:
  /// **'A cada 2 dias'**
  String get refresh2d;

  /// No description provided for @refreshWeekly.
  ///
  /// In pt, this message translates to:
  /// **'Uma vez por semana'**
  String get refreshWeekly;

  /// No description provided for @refreshNever.
  ///
  /// In pt, this message translates to:
  /// **'Nunca (só quando eu pedir)'**
  String get refreshNever;

  /// No description provided for @appearance.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearance;

  /// No description provided for @themeNavy.
  ///
  /// In pt, this message translates to:
  /// **'Azul'**
  String get themeNavy;

  /// No description provided for @themeBlack.
  ///
  /// In pt, this message translates to:
  /// **'Preto'**
  String get themeBlack;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Do sistema'**
  String get themeSystem;

  /// No description provided for @accentGold.
  ///
  /// In pt, this message translates to:
  /// **'Dourado'**
  String get accentGold;

  /// No description provided for @accentBlue.
  ///
  /// In pt, this message translates to:
  /// **'Azul'**
  String get accentBlue;

  /// No description provided for @accentGreen.
  ///
  /// In pt, this message translates to:
  /// **'Verde'**
  String get accentGreen;

  /// No description provided for @accentRed.
  ///
  /// In pt, this message translates to:
  /// **'Vermelho'**
  String get accentRed;

  /// No description provided for @accentPurple.
  ///
  /// In pt, this message translates to:
  /// **'Roxo'**
  String get accentPurple;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Do sistema'**
  String get languageSystem;

  /// No description provided for @listSection.
  ///
  /// In pt, this message translates to:
  /// **'Lista'**
  String get listSection;

  /// No description provided for @refreshListNow.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar a lista agora'**
  String get refreshListNow;

  /// No description provided for @refreshGuideNow.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar o guia agora'**
  String get refreshGuideNow;

  /// No description provided for @repeatedVersions.
  ///
  /// In pt, this message translates to:
  /// **'Versões repetidas'**
  String get repeatedVersions;

  /// No description provided for @display.
  ///
  /// In pt, this message translates to:
  /// **'Exibição'**
  String get display;

  /// No description provided for @showHidden.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar itens ocultos'**
  String get showHidden;

  /// No description provided for @perfMonitor.
  ///
  /// In pt, this message translates to:
  /// **'Monitor de desempenho (FPS)'**
  String get perfMonitor;

  /// No description provided for @perfMonitorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Painel sobre o vídeo e histórico em desempenho.csv'**
  String get perfMonitorSubtitle;

  /// No description provided for @profileSection.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileSection;

  /// No description provided for @editCurrentProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil atual'**
  String get editCurrentProfile;

  /// No description provided for @perfLogAt.
  ///
  /// In pt, this message translates to:
  /// **'Gravando o histórico em {path}'**
  String perfLogAt(String path);

  /// No description provided for @perfUi.
  ///
  /// In pt, this message translates to:
  /// **'Interface  {fps} FPS · {slow} lentos · pior {worst} ms'**
  String perfUi(String fps, String slow, String worst);

  /// No description provided for @perfVideo.
  ///
  /// In pt, this message translates to:
  /// **'Vídeo      {fps} de {source} FPS · hw {hw}'**
  String perfVideo(String fps, String source, String hw);

  /// No description provided for @perfDrops.
  ///
  /// In pt, this message translates to:
  /// **'Descartes  {rate}/s · {count} em 60 s'**
  String perfDrops(String rate, int count);

  /// No description provided for @perfReserve.
  ///
  /// In pt, this message translates to:
  /// **'Reserva    {seconds} s'**
  String perfReserve(String seconds);

  /// No description provided for @perfLoadingTag.
  ///
  /// In pt, this message translates to:
  /// **' · CARREGANDO'**
  String get perfLoadingTag;

  /// No description provided for @perfLegend.
  ///
  /// In pt, this message translates to:
  /// **'branco: interface · azul: vídeo · vermelho: carregando'**
  String get perfLegend;

  /// No description provided for @errCertHint.
  ///
  /// In pt, this message translates to:
  /// **'Se você confia neste servidor, marque \"Aceitar o certificado inválido\" em Editar perfil.'**
  String get errCertHint;

  /// No description provided for @errSelfSigned.
  ///
  /// In pt, this message translates to:
  /// **'o servidor usa um certificado autoassinado.'**
  String get errSelfSigned;

  /// No description provided for @errCertExpired.
  ///
  /// In pt, this message translates to:
  /// **'o certificado do servidor está vencido (ou a data do PC está errada).'**
  String get errCertExpired;

  /// No description provided for @errCertHost.
  ///
  /// In pt, this message translates to:
  /// **'o certificado do servidor é de outro domínio.'**
  String get errCertHost;

  /// No description provided for @errCertUnknownCa.
  ///
  /// In pt, this message translates to:
  /// **'o certificado do servidor vem de uma autoridade desconhecida.'**
  String get errCertUnknownCa;

  /// No description provided for @errNoTls.
  ///
  /// In pt, this message translates to:
  /// **'o servidor não fala TLS nesta porta; tente http:// no lugar de https://.'**
  String get errNoTls;

  /// No description provided for @errTls.
  ///
  /// In pt, this message translates to:
  /// **'falha de TLS/certificado ao conectar'**
  String get errTls;

  /// No description provided for @errInvalidUrl.
  ///
  /// In pt, this message translates to:
  /// **'URL inválida (use http:// ou https://)'**
  String get errInvalidUrl;

  /// No description provided for @errNoResponse.
  ///
  /// In pt, this message translates to:
  /// **'o servidor parou de responder'**
  String get errNoResponse;

  /// No description provided for @errDns.
  ///
  /// In pt, this message translates to:
  /// **'não foi possível resolver o endereço do servidor (DNS). A operadora pode estar bloqueando, ou o endereço mudou.'**
  String get errDns;

  /// No description provided for @errConnection.
  ///
  /// In pt, this message translates to:
  /// **'falha de conexão ({detail})'**
  String errConnection(String detail);

  /// No description provided for @errNetwork.
  ///
  /// In pt, this message translates to:
  /// **'rede'**
  String get errNetwork;

  /// No description provided for @errIncomplete.
  ///
  /// In pt, this message translates to:
  /// **'o download chegou incompleto'**
  String get errIncomplete;

  /// No description provided for @errBadHttp.
  ///
  /// In pt, this message translates to:
  /// **'resposta HTTP inválida: {detail}'**
  String errBadHttp(String detail);

  /// No description provided for @errForbidden.
  ///
  /// In pt, this message translates to:
  /// **'o servidor recusou o acesso (HTTP {status}). Confira usuário e senha ou se a lista expirou.'**
  String errForbidden(String status);

  /// No description provided for @errEmpty.
  ///
  /// In pt, this message translates to:
  /// **'o servidor devolveu uma resposta vazia'**
  String get errEmpty;

  /// No description provided for @errHttp.
  ///
  /// In pt, this message translates to:
  /// **'o servidor respondeu HTTP {code}'**
  String errHttp(int code);

  /// No description provided for @errTooSlow.
  ///
  /// In pt, this message translates to:
  /// **'o servidor está mandando os dados devagar demais'**
  String get errTooSlow;

  /// No description provided for @errTooLong.
  ///
  /// In pt, this message translates to:
  /// **'o download passou de {minutes} min e foi cancelado'**
  String errTooLong(int minutes);

  /// No description provided for @errGuideFileNotFound.
  ///
  /// In pt, this message translates to:
  /// **'arquivo do guia não encontrado'**
  String get errGuideFileNotFound;

  /// No description provided for @errGuideFormat.
  ///
  /// In pt, this message translates to:
  /// **'formato do guia não reconhecido'**
  String get errGuideFormat;

  /// No description provided for @errNoGuideSource.
  ///
  /// In pt, this message translates to:
  /// **'nenhuma fonte de guia disponível'**
  String get errNoGuideSource;

  /// No description provided for @errServerResponse.
  ///
  /// In pt, this message translates to:
  /// **'resposta do servidor não reconhecida'**
  String get errServerResponse;

  /// No description provided for @errNoMeta.
  ///
  /// In pt, this message translates to:
  /// **'o servidor não devolveu notas nem datas'**
  String get errNoMeta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
