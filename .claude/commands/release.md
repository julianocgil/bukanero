---
description: Gera o build release e atualiza o app do menu
---
Rode `flutter analyze && flutter test`; se passar, `flutter build linux --release`.
Se falhar por GTK (PkgConfig::GTK / gtk-3.0), sugira `sudo apt install --reinstall libgtk-3-dev` e `flutter clean`.
Depois rode `~/.local/bin/atualizar-meuiptv` se existir.
