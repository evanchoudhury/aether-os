#!/bin/bash -e
# Install the Lab Mode GTK panel and its launcher entry.
install -v -m 755 files/usr/bin/aether-labmode-panel "${ROOTFS_DIR}/usr/bin/aether-labmode-panel"
install -v -d -m 755 "${ROOTFS_DIR}/usr/share/applications"
install -v -m 644 files/usr/share/applications/aether-labmode.desktop \
	"${ROOTFS_DIR}/usr/share/applications/aether-labmode.desktop"
