#!/bin/bash -e
# Install AETHER Lab Mode into the image rootfs. install -m sets the right mode
# regardless of the source file's bits (so Windows-authored files are fine).

# Privileged scripts (root-executed via pkexec), argument-free.
install -v -d -m 755 "${ROOTFS_DIR}/usr/libexec/aether"
install -v -m 755 files/usr/libexec/aether/lab-arm    "${ROOTFS_DIR}/usr/libexec/aether/lab-arm"
install -v -m 755 files/usr/libexec/aether/lab-disarm "${ROOTFS_DIR}/usr/libexec/aether/lab-disarm"

# Unprivileged control CLI.
install -v -m 755 files/usr/bin/aether-labmode "${ROOTFS_DIR}/usr/bin/aether-labmode"

# Firewall profiles.
install -v -d -m 755 "${ROOTFS_DIR}/etc/aether/nftables"
install -v -m 644 files/etc/aether/nftables/everyday.nft "${ROOTFS_DIR}/etc/aether/nftables/everyday.nft"
install -v -m 644 files/etc/aether/nftables/research.nft "${ROOTFS_DIR}/etc/aether/nftables/research.nft"

# Polkit policy (ties pkexec on the exact script paths to admin auth).
install -v -d -m 755 "${ROOTFS_DIR}/usr/share/polkit-1/actions"
install -v -m 644 files/usr/share/polkit-1/actions/com.aether.labmode.policy \
	"${ROOTFS_DIR}/usr/share/polkit-1/actions/com.aether.labmode.policy"

# Boot-safe firewall unit.
install -v -m 644 files/etc/systemd/system/aether-firewall.service \
	"${ROOTFS_DIR}/etc/systemd/system/aether-firewall.service"

on_chroot <<EOF
systemctl enable aether-firewall.service
EOF
