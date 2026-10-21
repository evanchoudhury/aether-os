#!/bin/bash -e
# Install AETHER theming (GTK + labwc + waybar) into the image rootfs.

# GTK 3 + 4: dark + accent overrides, Inter UI font.
for v in gtk-3.0 gtk-4.0; do
	install -v -d -m 755 "${ROOTFS_DIR}/etc/${v}"
	install -v -m 644 "files/etc/${v}/settings.ini" "${ROOTFS_DIR}/etc/${v}/settings.ini"
	install -v -m 644 "files/etc/${v}/gtk.css"       "${ROOTFS_DIR}/etc/${v}/gtk.css"
done

# labwc theme + config.
install -v -d -m 755 "${ROOTFS_DIR}/etc/xdg/labwc"
install -v -m 644 files/etc/xdg/labwc/rc.xml            "${ROOTFS_DIR}/etc/xdg/labwc/rc.xml"
install -v -m 644 files/etc/xdg/labwc/themerc-override  "${ROOTFS_DIR}/etc/xdg/labwc/themerc-override"

# waybar config + style + Lab Mode module.
install -v -d -m 755 "${ROOTFS_DIR}/etc/xdg/waybar"
install -v -m 644 files/etc/xdg/waybar/config    "${ROOTFS_DIR}/etc/xdg/waybar/config"
install -v -m 644 files/etc/xdg/waybar/style.css "${ROOTFS_DIR}/etc/xdg/waybar/style.css"
install -v -m 755 files/usr/bin/aether-labmode-waybar "${ROOTFS_DIR}/usr/bin/aether-labmode-waybar"
install -v -m 755 files/usr/bin/aether-nightlight     "${ROOTFS_DIR}/usr/bin/aether-nightlight"
