# Bukanero

Player IPTV pessoal para Linux desktop (Flutter + media_kit), privacy-first, sem SDKs de terceiros.
Antes se chamava "Meu IPTV"; a pasta do projeto continua `~/meu_iptv`. App id: `io.github.julianocgil.Bukanero`.
Meta: publicar no Flathub (GPL-3.0). Idioma da conversa: português do Brasil.
UI em 6 idiomas (pt, en, es, fr, de, it): textos em `lib/l10n/app_*.arb` (o modelo é o `app_pt.arb`),
lidos pelo `tr` global de `lib/l10n/tr.dart`. Frase nova na tela entra nos 6 arquivos; nada de texto
solto no código.

## Estrutura
- `lib/domain/` modelos puros (Channel, Section, Profile, series, sort_mode, stream_id)
- `lib/data/` M3U parser, download, SQLite (catalog/series/meta/epg/user_data), cache de imagens, profile_store
- `lib/ui/` home_page, item_views, cover_image, series_dialog, player_view, profile_dialog,
  guide_page (grade do EPG), perf_monitor (FPS), category_picker, video_health
- `lib/domain/grouping.dart` agrupamento de versões (aprende as marcas da própria lista);
  `lib/data/groups_db.dart` guarda os cartões; `tool/group_report.dart` gera o relatório de conferência
- `test/` testes por módulo
- `packages/media_kit_video/` cópia local do 2.0.1 com o PR media-kit#1466 (vídeo pela GPU no
  Flutter 3.38+), via `dependency_overrides`, e o `updateShouldNotify` invertido do tema dos controles
  corrigido (`material_desktop.dart`). Remover quando as correções saírem oficiais.

## Comandos
- Verificar: `flutter analyze && flutter test` (sempre rodar antes de dizer que terminou)
- Rodar: `flutter run -d linux`
- Release: `flutter build linux --release`
- Sempre execute a partir de `~/meu_iptv`.

## Dados do usuário
Ficam em `~/.local/share/bukanero/` (respeita XDG_DATA_HOME): um banco SQLite por perfil
(catalog, series, userdata, epg, meta), cache de playlist, `img/`, `profiles.json`,
`desempenho.csv` (histórico do monitor de FPS, só números). Na primeira execução com o nome novo,
a pasta antiga `meu_iptv/` é movida para `bukanero/`.

## Regras inegociáveis
- NUNCA ler, imprimir, copiar ou commitar `minhalista.m3u`, qualquer `*.m3u/*.m3u8` ou `profiles.json`:
  contêm URL, usuário e senha do provedor.
- Nunca escrever credenciais, hosts reais ou URLs da lista em código, testes, logs, mensagens de erro ou commits.
  Testes usam dados fictícios.
- Nada é ocultado/bloqueado automaticamente (nem conteúdo adulto): quem decide é o usuário.
- Só consultar o servidor da própria lista do usuário. Sem telemetria, sem SDKs de terceiros,
  sem serviços externos (ex.: TMDB) sem autorização explícita.
- TLS inseguro só via `allowInsecure` por perfil e apenas para o mesmo host.
- Edições em vários pontos: confirmar que todos os trechos foram localizados antes de gravar (tudo ou nada).
- Strict analysis ligado: sem `print`, aspas simples, tipos explícitos, vírgulas finais.

## Pendências conhecidas
- Ordem automática por resolução medida no player (hoje: marca mais frequente + tabela de qualidade)
- EPG por nome do canal: revisar canais regionais sem guia próprio
- Flathub: manifesto de entrada em `linux/packaging/flatpak/flatpak-flutter.yml` (libass, libplacebo e
  libmpv compilados; app pelo flatpak-flutter, sem internet). Gerar com o flatpak-flutter e, no
  `generated/sources/pubspec.json`, tirar o download do libsqlite3 e o patch do sqlite3 (o app usa o
  SQLite do runtime via `sqlite-system.yaml`). Testado localmente; falta repositório público e envio.
  Descrição da loja: `linux/packaging/*.metainfo.xml`; capturas em `linux/packaging/screenshots/`
  (lista de demonstração com conteúdo livre, nunca a lista do usuário).
- PC antigo (Intel HD 4000) lento em 4K: rodar `vainfo` lá e mandar o desempenho.csv; provável falta do
  driver `i965-va-driver` (a HD 4000 não usa o intel-media-va-driver) e HEVC 4K sem decodificação na placa.
  (O .deb 0.4.0 já recomenda `i965-va-driver`.)
- Fonte embutida (OFL: Nunito/Inter/Figtree) — combinar o download dos arquivos antes
