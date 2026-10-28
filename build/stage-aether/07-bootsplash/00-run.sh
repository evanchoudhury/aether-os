#!/bin/bash -e
# Install the AETHER Plymouth boot splash and make it the default, so the box
# shows the AETHER logo at boot instead of the rainbow screen + kernel text.
# Runs on the build host; ${ROOTFS_DIR} and on_chroot are provided by pi-gen.
# [STATUS: UNTESTED] Plymouth on the Pi needs an initramfs to appear early, so we
# enable auto_initramfs. Verify on real Pi 4 hardware (QEMU has no GPU, so the
# splash cannot be seen there).

install -v -d -m 755 "${ROOTFS_DIR}/usr/share/plymouth/themes/aether"
cp -v files/usr/share/plymouth/themes/aether/* \
      "${ROOTFS_DIR}/usr/share/plymouth/themes/aether/"

on_chroot <<'EOF'
set -e
# Make 'aether' the default theme (two mechanisms, whichever the image supports).
if command -v plymouth-set-default-theme >/dev/null 2>&1; then
  plymouth-set-default-theme aether || true
fi
update-alternatives --install /usr/share/plymouth/themes/default.plymouth \
  default.plymouth /usr/share/plymouth/themes/aether/aether.plymouth 200 || true
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/aether/aether.plymouth || true
# Rebuild the initramfs so the splash is embedded and starts early in boot.
update-initramfs -u || true
EOF

# Boot config lives under /boot/firmware on trixie (fallback to /boot).
BOOT="${ROOTFS_DIR}/boot/firmware"; [ -d "$BOOT" ] || BOOT="${ROOTFS_DIR}/boot"
CMD="$BOOT/cmdline.txt"; CFG="$BOOT/config.txt"

# cmdline.txt is a SINGLE line: add quiet + splash, hide the kernel logo, blank
# the console cursor. Append each option once, to line 1 only.
if [ -f "$CMD" ]; then
  for opt in quiet splash plymouth.ignore-serial-consoles logo.nologo vt.global_cursor_default=0; do
    grep -qw "$opt" "$CMD" || sed -i "1 s|\$| $opt|" "$CMD"
  done
else
  echo "warn: $CMD not found; skipping cmdline splash options" >&2
fi

# config.txt: hide the rainbow splash; generate an initramfs so Plymouth is early.
if [ -f "$CFG" ]; then
  grep -q '^disable_splash=1' "$CFG" || echo 'disable_splash=1' >> "$CFG"
  grep -q '^auto_initramfs=1' "$CFG" || echo 'auto_initramfs=1' >> "$CFG"
else
  echo "warn: $CFG not found; skipping disable_splash/auto_initramfs" >&2
fi
