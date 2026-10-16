#!/bin/bash -e
# Install the AETHER session config into the image rootfs and enable it.
# Runs on the build host; ${ROOTFS_DIR} and on_chroot are provided by pi-gen.

install -v -m 644 files/greetd-config.toml "${ROOTFS_DIR}/etc/greetd/config.toml"
install -v -d -m 755 "${ROOTFS_DIR}/etc/xdg/labwc"
install -v -m 644 files/labwc-autostart "${ROOTFS_DIR}/etc/xdg/labwc/autostart"

on_chroot <<EOF
systemctl enable greetd
systemctl set-default graphical.target
EOF
