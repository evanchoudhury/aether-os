#!/bin/bash -e
# Install the AETHER security-tool launchers, report capture, and labwc menu.

install -v -m 755 files/usr/bin/aether-tool    "${ROOTFS_DIR}/usr/bin/aether-tool"
install -v -m 755 files/usr/bin/aether-capture "${ROOTFS_DIR}/usr/bin/aether-capture"
install -v -m 755 files/usr/bin/aether-search  "${ROOTFS_DIR}/usr/bin/aether-search"
install -v -m 755 files/usr/bin/aether-noticenter "${ROOTFS_DIR}/usr/bin/aether-noticenter"
install -v -m 755 files/usr/bin/aether-assistant "${ROOTFS_DIR}/usr/bin/aether-assistant"
install -v -m 755 files/usr/bin/aether-labs       "${ROOTFS_DIR}/usr/bin/aether-labs"
install -v -m 755 files/usr/bin/aether-lab-target "${ROOTFS_DIR}/usr/bin/aether-lab-target"
install -v -m 755 files/usr/bin/aether-scope       "${ROOTFS_DIR}/usr/bin/aether-scope"
install -v -m 755 files/usr/bin/aether-scope-panel "${ROOTFS_DIR}/usr/bin/aether-scope-panel"
install -v -m 755 files/usr/bin/aether-report      "${ROOTFS_DIR}/usr/bin/aether-report"
install -v -m 755 files/usr/bin/aether-store       "${ROOTFS_DIR}/usr/bin/aether-store"

# Tool Store catalog (vetted extra tools, installed on demand).
install -v -d -m 755 "${ROOTFS_DIR}/usr/share/aether/store"
install -v -m 644 files/usr/share/aether/store/catalog.json "${ROOTFS_DIR}/usr/share/aether/store/catalog.json"

# Engagement Scope default targets (this machine, so Guided Labs work out of the box).
install -v -d -m 755 "${ROOTFS_DIR}/etc/aether/scope"
install -v -m 644 files/etc/aether/scope/targets.conf "${ROOTFS_DIR}/etc/aether/scope/targets.conf"

# AETHER Assistant knowledge base (curated, offline).
install -v -d -m 755 "${ROOTFS_DIR}/usr/share/aether/assistant"
install -v -m 644 files/usr/share/aether/assistant/kb.json "${ROOTFS_DIR}/usr/share/aether/assistant/kb.json"

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

cat > "$apps/aether-search.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Search
Comment=Find apps and files (Spotlight-style). Shortcut: Super+Space
Exec=aether-search
Icon=system-search
Terminal=false
Categories=Utility;System;
EOF
chmod 644 "$apps/aether-search.desktop"

cat > "$apps/aether-noticenter.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Notification Center
Comment=Collected notifications (macOS-style). Shortcut: Super+N
Exec=aether-noticenter
Icon=preferences-system-notifications
Terminal=false
Categories=Utility;System;
EOF
chmod 644 "$apps/aether-noticenter.desktop"

cat > "$apps/aether-assistant.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Assistant
Comment=Offline tool-coach: explains tools and safe starter commands. Shortcut: Super+A
Exec=aether-assistant
Icon=help-browser
Terminal=false
Categories=Utility;System;Education;
EOF
chmod 644 "$apps/aether-assistant.desktop"

cat > "$apps/aether-labs.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Guided Labs
Comment=Practice the tools legally on a safe, local, intentionally-vulnerable target
Exec=aether-labs
Icon=applications-science
Terminal=false
Categories=Education;System;Security;
EOF
chmod 644 "$apps/aether-labs.desktop"

cat > "$apps/aether-scope.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Engagement Scope
Comment=Define authorized targets and check a command before you run it
Exec=aether-scope-panel
Icon=security-high
Terminal=false
Categories=System;Security;
EOF
chmod 644 "$apps/aether-scope.desktop"

cat > "$apps/aether-report.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Generate Report
Comment=Compile your captured findings into one shareable, printable HTML report
Exec=aether-report
Icon=document-new
Terminal=false
Categories=Office;System;Security;
EOF
chmod 644 "$apps/aether-report.desktop"

cat > "$apps/aether-store.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Tool Store
Comment=Browse and add vetted extra security tools (installed on demand)
Exec=aether-store
Icon=system-software-install
Terminal=false
Categories=System;Security;
EOF
chmod 644 "$apps/aether-store.desktop"
