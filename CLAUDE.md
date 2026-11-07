# Meu IPTV

Player IPTV pessoal para Linux desktop (Flutter + media_kit), privacy-first, sem SDKs de terceiros.
Meta: empacotar como Flatpak. Idioma da conversa e da UI: português do Brasil.

## Estrutura
- `lib/domain/` modelos puros (Channel, Section, Profile, series, sort_mode, stream_id)
- `lib/data/` M3U parser, download, SQLite (catalog/series/meta/epg/user_data), cache de imagens, profile_store
- `lib/ui/` home_page, item_views, cover_image, series_dialog, player_bar, profile_dialog
- `test/` testes por módulo

## Comandos
- Verificar: `flutter analyze && flutter test` (sempre rodar antes de dizer que terminou)
- Rodar: `flutter run -d linux`
- Release: `flutter build linux --release`
- Sempre execute a partir de `~/meu_iptv`.

## Dados do usuário
Ficam em `~/.local/share/meu_iptv/` (respeita XDG_DATA_HOME): um banco SQLite por perfil
(catalog, series, userdata, epg, meta), cache de playlist, `img/`, `profiles.json`.

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
- Nota (rating) sobre as capas
- Build release falhando por GTK (`libgtk-3-dev`; depois `flutter clean`)
- EPG por nome do canal via xmltv.php do servidor (baixa prioridade)
- Favoritos/continuar assistindo, atalhos de teclado, tela cheia
- Flatpak, remoto privado no GitHub
