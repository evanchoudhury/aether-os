#!/bin/bash -e
# Install the AETHER security-tool launchers, report capture, and labwc menu.

install -v -m 755 files/usr/bin/aether-tool    "${ROOTFS_DIR}/usr/bin/aether-tool"
install -v -m 755 files/usr/bin/aether-capture "${ROOTFS_DIR}/usr/bin/aether-capture"

install -v -d -m 755 "${ROOTFS_DIR}/etc/xdg/labwc"
install -v -m 644 files/etc/xdg/labwc/menu.xml "${ROOTFS_DIR}/etc/xdg/labwc/menu.xml"

apps="${ROOTFS_DIR}/usr/share/applications"
install -v -d -m 755 "$apps"

# Generate a .desktop launcher per CLI tool (wireshark ships its own GUI entry).
# name|Display Name|categories
cli_tools="
nmap|Nmap (network scan)|Network
tcpdump|tcpdump (packet dump)|Network
aircrack-ng|Aircrack-ng (wireless)|Network
john|John the Ripper (passwords)|Security
hydra|Hydra (login brute)|Security
nikto|Nikto (web scan)|Security
sqlmap|sqlmap (SQL injection)|Security
"
echo "$cli_tools" | while IFS='|' read -r cmd name cats; do
	[ -n "$cmd" ] || continue
	cat > "$apps/aether-$cmd.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=aether-tool $cmd
Icon=utilities-terminal
Terminal=false
Categories=System;Security;$cats;
EOF
	chmod 644 "$apps/aether-$cmd.desktop"
done

cat > "$apps/aether-capture.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Capture Finding
Comment=Screenshot, annotate, and append to the findings log
Exec=aether-capture
Icon=applets-screenshooter
Terminal=false
Categories=System;Security;
EOF
chmod 644 "$apps/aether-capture.desktop"
