#!/bin/bash -e
# Install LocalSend — AirDrop-style, cross-platform (iPhone/Android/Win/Mac/Linux)
# local file transfer. It isn't in Debian apt, so we install the upstream arm64
# .deb (pinned for reproducibility); apt resolves its deps (libayatana-appindicator).

LS_VER=1.18.2
LS_URL="https://github.com/localsend/localsend/releases/download/v${LS_VER}/LocalSend-${LS_VER}-linux-arm-64.deb"

# System-wide macOS-style notification theme (mako reads /etc/xdg/mako/config):
# rounded, translucent, top-right — used for AirDrop receive pop-ups and more.
install -v -d -m 755 "${ROOTFS_DIR}/etc/xdg/mako"
install -v -m 644 files/etc/xdg/mako/config "${ROOTFS_DIR}/etc/xdg/mako/config"

on_chroot <<EOF
set -e
cd /tmp
curl -fsSL -o localsend.deb "${LS_URL}"
apt-get install -y ./localsend.deb
rm -f localsend.deb
EOF
