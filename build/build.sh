#!/usr/bin/env bash
# Build the AETHER OS v0.1 image with pi-gen.
# [ENV: DEV_HOST] Run on Linux or WSL2 with Docker installed. Does NOT run on
# native Windows (pi-gen needs loop devices + binfmt/qemu). [STATUS: UNTESTED]
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
PIGEN_DIR="${PIGEN_DIR:-$HERE/.pi-gen}"
# pi-gen's 'bookworm' branch is 32-bit armhf only (it hardcodes --arch armhf and
# the raspbian mirror). 64-bit arm64 images come from the 'arm64' branch. Pin a
# dated arm64 tag for reproducibility once you pick one.
PIGEN_REF="${PIGEN_REF:-arm64}"

if ! command -v docker >/dev/null 2>&1; then
  echo "error: docker is required (run this in Linux/WSL2 with Docker)." >&2
  exit 1
fi

if [ ! -d "$PIGEN_DIR" ]; then
  echo ">> cloning pi-gen ($PIGEN_REF)"
  git clone --branch "$PIGEN_REF" --depth 1 \
    https://github.com/RPi-Distro/pi-gen "$PIGEN_DIR"
fi

echo ">> installing AETHER config + stage into pi-gen"
cp "$HERE/config" "$PIGEN_DIR/config"
rm -rf "$PIGEN_DIR/stage-aether"
cp -r "$HERE/stage-aether" "$PIGEN_DIR/stage-aether"
# pi-gen skips non-executable run scripts silently; files authored on Windows
# lack the exec bit, so set it here or the session config never installs.
find "$PIGEN_DIR/stage-aether" -name '*.sh' -exec chmod +x {} +
# Only stage-aether should export an image, not the Lite stage.
rm -f "$PIGEN_DIR/stage2/EXPORT_IMAGE"
# pi-gen's build.sh sources config, then hardcodes `export ARCH=armhf`, which
# clobbers ARCH=arm64 from our config. Force arm64 (our Pi 4 target) directly.
sed -i 's/^export ARCH=armhf$/export ARCH=arm64/' "$PIGEN_DIR/build.sh"

echo ">> building (this takes a while)"
cd "$PIGEN_DIR"
./build-docker.sh

echo ">> done. Image(s) + checksums in: $PIGEN_DIR/deploy/"
