#!/usr/bin/env bash
# Lab Mode regression check (eng review T2): disarm must FULLY revert arm.
# [ENV: TARGET_RPI4] Run ON the booted image as a user who can authenticate for
# polkit. Needs root for the comparison loads. Not runnable on the Windows dev
# host (no nft). [STATUS: UNTESTED]
#
#   sudo ./test-labmode.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "run as root (needs nft)" >&2; exit 2
fi

aether-labmode arm    >/dev/null
armed="$(nft list ruleset)"

aether-labmode disarm >/dev/null
after="$(nft list ruleset)"

# Ground truth for 'everyday'.
nft -f /etc/aether/nftables/everyday.nft
everyday="$(nft list ruleset)"

fail=0
if [ "$armed" = "$everyday" ]; then
	echo "FAIL: armed ruleset is identical to everyday (arm had no effect)"; fail=1
fi
if [ "$after" != "$everyday" ]; then
	echo "FAIL: disarm did not fully revert to the everyday profile"; fail=1
fi

[ "$fail" -eq 0 ] && echo "PASS: arm differs from everyday; disarm reverts cleanly"
exit "$fail"
