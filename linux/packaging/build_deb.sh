#!/usr/bin/env bash
# Gera build/deb/bukanero_<versão>_amd64.deb a partir do build release.
# Instala em /opt/bukanero, com atalho no menu e o comando `bukanero`.
# O pacote leva só o app: nenhuma lista, perfil ou dado do usuário.
set -euo pipefail

cd "$(dirname "$0")/../.."
APP_ID=io.github.julianocgil.Bukanero
VERSION=$(sed -n 's/^version: *\([0-9.]*\).*/\1/p' pubspec.yaml)
ARCH=amd64
OUT=build/deb
ROOT="$OUT/bukanero_${VERSION}_${ARCH}"

flutter build linux --release
BUNDLE=build/linux/x64/release/bundle

rm -rf "$ROOT"
mkdir -p "$ROOT/DEBIAN" "$ROOT/opt/bukanero" "$ROOT/usr/bin" \
  "$ROOT/usr/share/applications" "$ROOT/usr/share/icons/hicolor/scalable/apps"
cp -r "$BUNDLE"/. "$ROOT/opt/bukanero/"
ln -s /opt/bukanero/bukanero "$ROOT/usr/bin/bukanero"
cp "linux/packaging/$APP_ID.desktop" "$ROOT/usr/share/applications/"
cp "linux/packaging/$APP_ID.svg" "$ROOT/usr/share/icons/hicolor/scalable/apps/"

SIZE=$(du -sk "$ROOT" | cut -f1)
cat > "$ROOT/DEBIAN/control" <<EOF
Package: bukanero
Version: $VERSION
Architecture: $ARCH
Maintainer: Juliano <julianocgil@users.noreply.github.com>
Installed-Size: $SIZE
Depends: libc6, libstdc++6, libgcc-s1, libglib2.0-0t64, libgtk-3-0t64, libepoxy0, libegl1, libmpv2
Recommends: mesa-va-drivers
Section: video
Priority: optional
Description: Player IPTV pessoal para Linux
 Assista aos canais ao vivo, filmes e séries da sua lista IPTV,
 com guia de programação. Sem telemetria e sem serviços externos.
EOF

# Atualiza o menu e os ícones depois de instalar ou remover.
for s in postinst postrm; do
  cat > "$ROOT/DEBIAN/$s" <<'EOF'
#!/bin/sh
set -e
command -v update-desktop-database >/dev/null && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -t /usr/share/icons/hicolor || true
EOF
  chmod 755 "$ROOT/DEBIAN/$s"
done

dpkg-deb --root-owner-group --build "$ROOT" "$OUT/bukanero_${VERSION}_${ARCH}.deb"
rm -rf "$ROOT"
echo "Pacote: $OUT/bukanero_${VERSION}_${ARCH}.deb"
