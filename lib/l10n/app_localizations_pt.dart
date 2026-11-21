// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get close => 'Fechar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get back => 'Voltar';

  @override
  String get now => 'Agora';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String errorPrefix(String error) {
    return 'Erro: $error';
  }

  @override
  String get settings => 'Configurações';

  @override
  String get favorites => 'Favoritos';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String categoriesCount(int count) {
    return '$count categorias';
  }

  @override
  String get searchCategory => 'Procurar categoria';

  @override
  String categoriesOf(String section) {
    return 'Categorias · $section';
  }

  @override
  String get liveChannels => 'Canais ao vivo';

  @override
  String get liveShort => 'Ao vivo';

  @override
  String get movies => 'Filmes';

  @override
  String get series => 'Séries';

  @override
  String get nothingHere => 'Nada por aqui';

  @override
  String get searchByName => 'Buscar pelo nome';

  @override
  String get clearSearch => 'Limpar a busca';

  @override
  String get shrinkList => 'Reduzir a lista (vídeo grande)';

  @override
  String get expandList => 'Ampliar a lista (vídeo pequeno)';

  @override
  String get continueWatching => 'Continuar assistindo';

  @override
  String get programGuide => 'Guia de programação';

  @override
  String get channelOrProgram => 'Canal ou programa';

  @override
  String get oneHourBefore => 'Uma hora antes';

  @override
  String get oneHourAfter => 'Uma hora depois';

  @override
  String get guideNoChannels =>
      'Nenhum canal desta lista tem programação no guia.';

  @override
  String channelsCount(int count) {
    return '$count canais';
  }

  @override
  String get watchNow => 'Assistir agora';

  @override
  String get openChannel => 'Abrir o canal';

  @override
  String get guideNotFound =>
      'Não achei o guia (EPG) nem na lista nem no servidor dela.';

  @override
  String get guideDeferred => 'Guia: atualização adiada até o vídeo parar';

  @override
  String get guideDownloading => 'Baixando o guia de programação...';

  @override
  String guideStatus(int programmes, int channels) {
    return 'Guia: $programmes programas, $channels canais com programação';
  }

  @override
  String guideError(String error) {
    return 'Guia: $error';
  }

  @override
  String get groupRepeatedVersions => 'Agrupar versões repetidas';

  @override
  String get groupingSubtitle =>
      'HD, FHD, 4K, dublado, legendado... num cartão só';

  @override
  String get reviewGroups => 'Revisar agrupamentos';

  @override
  String get reviewGroupsMenu => 'Revisar agrupamentos…';

  @override
  String separatedGroups(int count) {
    return 'Grupos separados ($count)';
  }

  @override
  String separatedGroupsMenu(int count) {
    return 'Grupos separados ($count)…';
  }

  @override
  String get noSeparatedGroups => 'Nenhum grupo separado.';

  @override
  String get regroup => 'Reagrupar';

  @override
  String get regroupAll => 'Reagrupar todos';

  @override
  String get separate => 'Separar';

  @override
  String get allRegrouped => 'Todos os grupos foram juntados de novo.';

  @override
  String groupSeparated(String name) {
    return 'Grupo \"$name\" separado. As versões aparecem soltas.';
  }

  @override
  String get versionsRegrouped => 'Versões juntadas de novo.';

  @override
  String versionsOfRegrouped(String name) {
    return 'As versões de \"$name\" foram juntadas de novo.';
  }

  @override
  String get preferredForgotten => 'As versões preferidas foram esquecidas.';

  @override
  String get forgetPreferred => 'Esquecer versões preferidas';

  @override
  String reviewIntro(int count) {
    return '$count grupos foram juntados só por nome e imagem. Os juntados só pelo nome vêm primeiro. Separe o que não for a mesma coisa.';
  }

  @override
  String get searchGroup => 'Procurar grupo';

  @override
  String get nothingToReview => 'Nada para revisar aqui.';

  @override
  String get reasonSameTvgId => 'mesmo tvg-id';

  @override
  String get reasonSameTmdb => 'mesmo TMDB';

  @override
  String get reasonSameNameYear => 'mesmo nome e ano';

  @override
  String get reasonSameNameImage => 'mesmo nome e imagem';

  @override
  String get reasonSameNameGuide => 'mesmo nome e canal do guia';

  @override
  String get reasonSameNameNumber => 'mesmo nome com número';

  @override
  String get reasonSameName => 'mesmo nome';

  @override
  String get reasonNumberedFamily => 'família numerada';

  @override
  String get versionDefault => 'Padrão';

  @override
  String get options => 'Opções';

  @override
  String get hide => 'Ocultar';

  @override
  String get unhide => 'Reexibir';

  @override
  String get regroupVersions => 'Juntar as versões de novo';

  @override
  String get addFavorite => 'Favoritar';

  @override
  String get removeFavorite => 'Tirar dos favoritos';

  @override
  String get favorited => 'Favorito';

  @override
  String get chooseVersion => 'Escolher a versão';

  @override
  String get yourPreference => '(sua preferência)';

  @override
  String get automatic => '(automática)';

  @override
  String get separateGroup => 'Separar este grupo';

  @override
  String get removeFromRecent => 'Tirar dos recentes';

  @override
  String get watch => 'Assistir';

  @override
  String get versions => 'Versões';

  @override
  String directedBy(String names) {
    return 'Direção: $names';
  }

  @override
  String castList(String names) {
    return 'Elenco: $names';
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
    return 'Episódio $number';
  }

  @override
  String get specials => 'Especiais';

  @override
  String seasonN(int number) {
    return 'Temporada $number';
  }

  @override
  String seasonsEpisodes(int seasons, int episodes) {
    return '$seasons temporada(s) · $episodes episódio(s)';
  }

  @override
  String get previousEpisodes => 'Episódios anteriores';

  @override
  String get nextEpisodes => 'Próximos episódios';

  @override
  String pageOf(int page, int pages) {
    return 'Página $page de $pages';
  }

  @override
  String get lastWatched => 'Último';

  @override
  String nextEpisodeIn(int seconds) {
    return 'Próximo episódio em ${seconds}s';
  }

  @override
  String seasonEpisodeShort(String season, String episode) {
    return 'T$season E$episode';
  }

  @override
  String get back15 => 'Voltar 15 s';

  @override
  String get forward15 => 'Avançar 15 s';

  @override
  String get previousEpisode => 'Episódio anterior';

  @override
  String get nextEpisode => 'Próximo episódio';

  @override
  String get mute => 'Tirar o som';

  @override
  String get unmute => 'Ligar o som';

  @override
  String liveStalledReconnecting(String name) {
    return '\"$name\" travou. Reconectando...';
  }

  @override
  String liveNotBack(String name) {
    return '\"$name\" não voltou. Tente de novo daqui a pouco.';
  }

  @override
  String liveSwitching(String from, String to) {
    return '$from travou. Mudando para $to...';
  }

  @override
  String noVersionOpened(String name) {
    return 'Nenhuma versão de \"$name\" abriu agora.';
  }

  @override
  String versionFailedTrying(String version, String next) {
    return 'A versão $version não abriu. Tentando $next...';
  }

  @override
  String versionFailedTitle(String version) {
    return 'A versão $version não abriu';
  }

  @override
  String tryAnotherVersion(String name) {
    return 'Quer tentar outra versão de \"$name\"?';
  }

  @override
  String listDownloadFailedUsingOld(String error) {
    return 'Não consegui baixar a lista ($error). Usando a lista anterior.';
  }

  @override
  String mbDownloaded(String mb) {
    return '$mb MB baixados';
  }

  @override
  String mbOf(String received, String total) {
    return '$received de $total MB';
  }

  @override
  String get queued => 'Na fila...';

  @override
  String get connecting => 'Conectando ao servidor...';

  @override
  String get preparingList => 'Preparando a lista nova...';

  @override
  String get listUpdatedAuto => 'Lista atualizada automaticamente.';

  @override
  String get listUpdated => 'Lista atualizada.';

  @override
  String listUpdateFailed(String error) {
    return 'Não consegui atualizar a lista ($error). Continuo com a anterior.';
  }

  @override
  String listUpdateFailedRetry(String error) {
    return 'Não consegui atualizar a lista ($error). Continuo com a anterior; tento de novo daqui a uma hora.';
  }

  @override
  String updatingListProgress(String progress) {
    return 'Atualizando a lista: $progress (pode continuar usando)';
  }

  @override
  String get updatingList => 'Atualizando a lista...';

  @override
  String get refreshListBackground => 'Atualizar a lista (em segundo plano)';

  @override
  String get firstDownload =>
      'Baixando e preparando a lista (só demora na primeira vez)...';

  @override
  String get metaNoServer =>
      'Não consegui identificar o servidor da lista para buscar notas e datas.';

  @override
  String metaLoaded(int rated, int movies, int ratedSeries, int series) {
    return 'Notas carregadas: $rated de $movies filmes, $ratedSeries de $series séries.';
  }

  @override
  String metaError(String error) {
    return 'Notas e datas: $error';
  }

  @override
  String sortBy(String mode) {
    return 'Ordenar: $mode';
  }

  @override
  String get sortListOrder => 'Ordem da lista';

  @override
  String get sortListOrderReverse => 'Ordem da lista (invertida)';

  @override
  String get sortRecent => 'Adicionados recentemente';

  @override
  String get sortRecentSeries => 'Adicionadas ou atualizadas recentemente';

  @override
  String get sortRating => 'Melhor nota';

  @override
  String get sortYear => 'Ano (mais novo)';

  @override
  String sortModeLoading(String mode) {
    return '$mode (carregando...)';
  }

  @override
  String sortModeUnavailable(String mode) {
    return '$mode (indisponível)';
  }

  @override
  String get profiles => 'Perfis';

  @override
  String get newProfileMenu => 'Novo perfil...';

  @override
  String get editProfileMenu => 'Editar perfil atual...';

  @override
  String get deleteProfileMenu => 'Excluir perfil atual';

  @override
  String get createProfile => 'Criar perfil';

  @override
  String deleteProfileTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteProfileBody =>
      'A lista baixada, o guia e os itens ocultos deste perfil também serão apagados.';

  @override
  String get newProfile => 'Novo perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get userName => 'Nome do usuário';

  @override
  String get playlistField => 'Playlist M3U (URL ou caminho do arquivo)';

  @override
  String get guideField => 'Guia XMLTV (opcional; vazio = detectar sozinho)';

  @override
  String get fillNameAndPlaylist => 'Preencha o nome e a playlist.';

  @override
  String get playlistUrlHint =>
      'Use uma URL http(s) ou o caminho de um arquivo.';

  @override
  String get guideUrlHint => 'Guia: use uma URL http(s) ou um arquivo XMLTV.';

  @override
  String get acceptInvalidCert =>
      'Aceitar o certificado inválido deste servidor';

  @override
  String get acceptInvalidCertHint =>
      'Só para listas em que você confia. Desmarcado é mais seguro.';

  @override
  String get autoRefreshList => 'Atualizar a lista sozinho';

  @override
  String get refresh6h => 'A cada 6 horas';

  @override
  String get refresh12h => 'A cada 12 horas';

  @override
  String get refresh24h => 'A cada 24 horas';

  @override
  String get refresh24hDefault => 'A cada 24 horas (padrão)';

  @override
  String get refresh2d => 'A cada 2 dias';

  @override
  String get refreshWeekly => 'Uma vez por semana';

  @override
  String get refreshNever => 'Nunca (só quando eu pedir)';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeNavy => 'Azul';

  @override
  String get themeBlack => 'Preto';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Do sistema';

  @override
  String get accentGold => 'Dourado';

  @override
  String get accentBlue => 'Azul';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentRed => 'Vermelho';

  @override
  String get accentPurple => 'Roxo';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Do sistema';

  @override
  String get listSection => 'Lista';

  @override
  String get refreshListNow => 'Atualizar a lista agora';

  @override
  String get refreshGuideNow => 'Atualizar o guia agora';

  @override
  String get repeatedVersions => 'Versões repetidas';

  @override
  String get display => 'Exibição';

  @override
  String get showHidden => 'Mostrar itens ocultos';

  @override
  String get perfMonitor => 'Monitor de desempenho (FPS)';

  @override
  String get perfMonitorSubtitle =>
      'Painel sobre o vídeo e histórico em desempenho.csv';

  @override
  String get profileSection => 'Perfil';

  @override
  String get editCurrentProfile => 'Editar perfil atual';

  @override
  String perfLogAt(String path) {
    return 'Gravando o histórico em $path';
  }

  @override
  String perfUi(String fps, String slow, String worst) {
    return 'Interface  $fps FPS · $slow lentos · pior $worst ms';
  }

  @override
  String perfVideo(String fps, String source, String hw) {
    return 'Vídeo      $fps de $source FPS · hw $hw';
  }

  @override
  String perfDrops(String rate, int count) {
    return 'Descartes  $rate/s · $count em 60 s';
  }

  @override
  String perfReserve(String seconds) {
    return 'Reserva    $seconds s';
  }

  @override
  String get perfLoadingTag => ' · CARREGANDO';

  @override
  String get perfLegend =>
      'branco: interface · azul: vídeo · vermelho: carregando';

  @override
  String get errCertHint =>
      'Se você confia neste servidor, marque \"Aceitar o certificado inválido\" em Editar perfil.';

  @override
  String get errSelfSigned => 'o servidor usa um certificado autoassinado.';

  @override
  String get errCertExpired =>
      'o certificado do servidor está vencido (ou a data do PC está errada).';

  @override
  String get errCertHost => 'o certificado do servidor é de outro domínio.';

  @override
  String get errCertUnknownCa =>
      'o certificado do servidor vem de uma autoridade desconhecida.';

  @override
  String get errNoTls =>
      'o servidor não fala TLS nesta porta; tente http:// no lugar de https://.';

  @override
  String get errTls => 'falha de TLS/certificado ao conectar';

  @override
  String get errInvalidUrl => 'URL inválida (use http:// ou https://)';

  @override
  String get errNoResponse => 'o servidor parou de responder';

  @override
  String get errDns =>
      'não foi possível resolver o endereço do servidor (DNS). A operadora pode estar bloqueando, ou o endereço mudou.';

  @override
  String errConnection(String detail) {
    return 'falha de conexão ($detail)';
  }

  @override
  String get errNetwork => 'rede';

  @override
  String get errIncomplete => 'o download chegou incompleto';

  @override
  String errBadHttp(String detail) {
    return 'resposta HTTP inválida: $detail';
  }

  @override
  String errForbidden(String status) {
    return 'o servidor recusou o acesso (HTTP $status). Confira usuário e senha ou se a lista expirou.';
  }

  @override
  String get errEmpty => 'o servidor devolveu uma resposta vazia';

  @override
  String errHttp(int code) {
    return 'o servidor respondeu HTTP $code';
  }

  @override
  String get errTooSlow => 'o servidor está mandando os dados devagar demais';

  @override
  String errTooLong(int minutes) {
    return 'o download passou de $minutes min e foi cancelado';
  }

  @override
  String get errGuideFileNotFound => 'arquivo do guia não encontrado';

  @override
  String get errGuideFormat => 'formato do guia não reconhecido';

  @override
  String get errNoGuideSource => 'nenhuma fonte de guia disponível';

  @override
  String get errServerResponse => 'resposta do servidor não reconhecida';

  @override
  String get errNoMeta => 'o servidor não devolveu notas nem datas';
}
