# Bukanero

A privacy-first IPTV player for the Linux desktop, built with Flutter and mpv.

**Bukanero does not include, sell or point to any content.** It only plays the
M3U playlists and XMLTV guides that *you* add, from providers you choose.
Nothing is collected: no telemetry, no accounts, no third-party services. The app
only talks to the server of your own playlist.

## Features

- Live channels, movies and series from M3U playlists (including Xtream-style servers)
- TV guide (XMLTV/EPG) with "now/next" and a full timeline
- **Smart version grouping**: HD, FHD, 4K, dubbed, subtitled... of the same channel
  or movie become a single card. The app learns the version marks from your own list.
- Automatic fallback: a frozen live channel reconnects and, if needed, switches to
  another version (4K → FHD → HD)
- Favorites, hidden items, "continue watching", ratings and dates when the server
  provides them
- Series with seasons, next-episode countdown and episode navigation
- Several profiles (one per list), themes (navy, black, light) and accent colors
- Hardware-accelerated video through mpv
- Available in Portuguese, English, Spanish, French, German and Italian

## Install

Get the latest version from the [Releases](https://github.com/julianocgil/bukanero/releases) page:

- **Any distribution (Flatpak):** download the `.flatpak` file and open it, or run
  `flatpak install --user bukanero_<version>_x86_64.flatpak`. The runtime comes from Flathub
  automatically.
- **Ubuntu / Debian:** download the `.deb` file and double-click it.

## Build from source

Requirements: Flutter (stable) and the Linux desktop toolchain, plus `libmpv-dev`.

```bash
flutter pub get
flutter build linux --release
```

Run the checks with `flutter analyze && flutter test`.

## Support

This is a personal project shared as is, without guaranteed support. Bug reports
are welcome in the issues. Questions about where to find playlists will not be
answered.

## License

[GPL-3.0](LICENSE). Bukanero uses [media_kit](https://github.com/media-kit/media-kit)
and [mpv](https://mpv.io/).
