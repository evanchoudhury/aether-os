# AETHER OS

A premium, macOS-inspired, security-hardened Linux desktop for the Raspberry Pi 4
— the beautiful, discoverable pentest box for people learning offensive security.
Signature feature: **Lab Mode**, a single toggle that arms the box (firewall
profile, tool group, scope banner) with a cinematic transition.

Open source. Design and plan: [docs/designs/aether-os.md](docs/designs/aether-os.md).

## Status

**v0.1 — image builds.** Produces a flashable, 64-bit **arm64** Raspberry Pi OS
image (Debian **trixie** base) with the full v0.1 slice baked in: labwc + waybar +
foot desktop, the themed design system, Lab Mode (pkexec/nftables), the 8 security
tools, and report capture. A real build produced
`image-<date>-aether-os.img.xz` (~800 MB) with all AETHER packages present and
zero armhf packages.

`[STATUS: TESTED_EMULATOR]` for the build (pi-gen under qemu in a container);
**boot on real Pi 4 hardware is still unverified** — flash it and check the
greetd→labwc session and Lab Mode arm/disarm.

Base note: the image is Debian **trixie** arm64, not bookworm — pi-gen's arm64
branch targets trixie, and its bookworm branch is 32-bit only. Trixie also carries
`swappy` and `fonts-jetbrains-mono`.

## Build

pi-gen runs on Linux or WSL2 with Docker (not native Windows — it needs loop
devices and binfmt/qemu).

```bash
cd build && ./build.sh
```

This clones [pi-gen](https://github.com/RPi-Distro/pi-gen), layers in the AETHER
config and custom stage, and builds. Output (`.img.xz` + `.sha256`) lands in
`build/.pi-gen/deploy/`. Pin a dated pi-gen tag for reproducibility:
`PIGEN_REF=2024-11-19-raspios-bookworm ./build.sh`.

## Releases (CI)

`.github/workflows/build-image.yml` builds on a `v*` tag (e.g. `git tag v0.1.0 &&
git push --tags`), on a native arm64 GitHub runner, then attaches the `.img.xz` +
`.sha256` to a GitHub Release. If you add a `GPG_PRIVATE_KEY` (+ `GPG_PASSPHRASE`)
Actions secret, it also attaches detached `.asc` signatures — no signing key ever
lives in the repo. Requires the project to be a GitHub repo first (`git init`,
push, add a remote). Native arm64 runners are free for public repos; private repos
need the paid larger-runner tier (or switch the runner to x86 + qemu, slower).

## Flash & first boot

Flash `build/.pi-gen/deploy/*.img.xz` with [Raspberry Pi
Imager](https://www.raspberrypi.com/software/) to a microSD or USB SSD, boot a
Pi 4. There are **no default credentials** — Raspberry Pi OS runs its first-boot
user-creation wizard. SSH is off by default.

## Verify (first hardware check)

1. It boots to a text login on VT1 (greetd).
2. Logging in starts labwc with waybar and a foot terminal visible.

If the session doesn't come up, that greetd→labwc handoff is the thing to debug
first (`build/stage-aether/01-session/`). It's the one part most likely to need
tuning on real hardware.

## Layout

```
build/
  config                 pi-gen config (base = Pi OS Lite 64-bit arm64)
  build.sh               clones pi-gen, layers AETHER in, builds (Linux/WSL2)
  stage-aether/          the AETHER overlay stage
    00-install-packages/ desktop packages (labwc, waybar, foot, greetd, nftables, polkit, ...)
    01-session/          greetd + labwc session config, enabled on first boot
    02-labmode/          Lab Mode: pkexec scripts, polkit policy, nft profiles, boot firewall
    03-theme/            design tokens applied: GTK (dark+accent), labwc theme, waybar + Lab Mode indicator
    04-panel/            Lab Mode GTK4 panel (arm/disarm toggle, animated scope banner) + launcher
    05-tools/            8 security tools + launchers, labwc AETHER menu, report capture
test/test-labmode.sh     arm/disarm firewall-revert check (run on the booted Pi)
docs/designs/            the design doc + engineering/design reviews
```

## Tools & report capture (scaffolded)

Eight starter tools (nmap, tcpdump, Wireshark, aircrack-ng, John, hydra, nikto,
sqlmap) are installed and surfaced two ways: `.desktop` launchers (so any future
dock/launcher sees them) and a right-click **AETHER menu** in labwc. CLI tools
open in a terminal via `aether-tool <name>` (shows `--help`, drops to a shell).
**No centered dock yet** — that needs a dock component and is a later piece; this
is the discoverability layer.

`aether-capture` (bound to **Print**) takes a region/full screenshot, opens it in
swappy to annotate, saves to `~/AETHER/findings/`, and appends an entry to
`findings.md` — a CTF/pentest writes itself as you go.

## Lab Mode (scaffolded)

`aether-labmode {arm|disarm|status}` — the unprivileged control (the GUI will call
the same CLI). `arm`/`disarm` go through `pkexec` to two fixed, argument-free root
scripts that swap the nftables profile; `status` reads `/run/aether/labmode`. The
box boots into the everyday (safe) firewall via `aether-firewall.service`. Arm
fails loudly and writes no state, so nothing shows ARMED unless the firewall
actually applied. Verify the revert with `sudo test/test-labmode.sh` on hardware.

The **Lab Mode panel** (`aether-labmode-panel`, GTK4) is the GUI toggle: it drives
the same CLI, slides the scope banner down when armed (~280ms, respects the system
reduce-animations setting), and commits to ARMED only when `arm` exits 0. Its
safety invariant is checked offline with `aether-labmode-panel --selftest`.
