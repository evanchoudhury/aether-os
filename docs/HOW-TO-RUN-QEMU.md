# AETHER OS — How to run the image in QEMU (every step)

This guide boots the AETHER OS disk image on your Windows laptop using QEMU,
which emulates a Raspberry Pi 4. No real Pi needed for this.

> **Read this first — the honest limits.**
> - The image is a **64-bit ARM (`arm64`) Raspberry Pi image**. It is NOT an x86
>   `.iso`. It will **not** boot in VirtualBox, VMware, or Hyper-V. QEMU is the
>   only way to run it on a PC.
> - QEMU's Pi 4 (`raspi4b`) emulation has **no GPU**. Your laptop's graphics card
>   **cannot** drive the emulated Pi's VideoCore, so the labwc desktop (the
>   wallpaper, the dock, the windows) **does not render in QEMU**. There is no
>   flag that turns your GPU on for this — the Pi's GPU simply isn't emulated.
> - QEMU usually has **no working network** for `raspi4b` either.
> - What QEMU *does* prove: the kernel boots, the disk/partitions are valid, the
>   root filesystem mounts, systemd starts, and the CLI userland (Lab Mode,
>   nftables, the security tools) is intact. It is a **boot + CLI smoke test.**
> - **The real desktop only appears on a real Pi 4.** Flash the `.img.xz` with
>   Raspberry Pi Imager when you have the hardware (see `README.md`).

---

## Step 1 — Install QEMU (one time)

1. Go to <https://www.qemu.org/download/> and click **Windows**.
2. Download the 64-bit installer (from the `w64` folder, e.g. the latest
   `qemu-w64-setup-*.exe`). You need **QEMU 9.1 or newer** — older versions do
   not have the `raspi4b` machine. (QEMU 11.x is fine; that's what this was
   tested on.)
3. Run the installer. Default install path is `C:\Program Files\qemu`.

## Step 2 — Check QEMU is on your PATH

Open **PowerShell** and run:

```powershell
qemu-system-aarch64 --version
```

- If you see a version number (9.1 or newer) → you're good, skip to Step 3.
- If you get *"not recognized"* → QEMU isn't on PATH. Either:
  - add `C:\Program Files\qemu` to your PATH (Settings → System → About →
    Advanced system settings → Environment Variables → edit `Path` → New), then
    open a **new** PowerShell, **or**
  - just call it by full path in Step 3:
    `& "C:\Program Files\qemu\qemu-system-aarch64.exe" --version`

## Step 3 — Go to the image folder

All the files live in `C:\Users\evanc\aether-out`. In PowerShell:

```powershell
cd C:\Users\evanc\aether-out
```

You should see `aether-os.img`, a `vm\` folder, `run-vm.cmd`, and `run-vm.sh`.

## Step 4 — Boot it

Easiest way — double-click **`run-vm.cmd`** in File Explorer, or in PowerShell:

```powershell
.\run-vm.cmd
```

That script runs the correct QEMU command for you (right kernel, device tree,
and disk). You don't have to type the long command yourself.

A terminal shows the **kernel boot log** (`-serial stdio`), and a QEMU window
opens for the framebuffer. Watch the log — you'll see:

```
Machine model: Raspberry Pi 4 Model B
... systemd ...
aether login:   (or a first-boot message)
```

That is success: the image booted on the emulated Pi 4.

## Step 5 — Stop it

- Close the QEMU window, **or**
- Press `Ctrl+C` in the terminal running the script.

---

## Expected: the "first-boot reboot loop"

On first boot the image runs the Raspberry Pi first-boot setup (it wants to
create your user account). Under QEMU there's no Pi firmware/network to finish
that, so the VM may **reboot in a loop** showing *"Detected first boot"* each
time. **This is an emulation limit, not a broken image** — on a real Pi 4 the
first-boot wizard finishes and asks you to create a username/password.

### Want a shell in QEMU anyway? (test-only)

To poke around the CLI inside the emulator, boot straight to a root shell:
edit the `-append "..."` line in `run-vm.cmd` to add `init=/bin/bash`, e.g.

```
-append "console=ttyAMA0,115200 root=PARTUUID=XXXXXXXX-02 rootfstype=ext4 rw rootwait init=/bin/bash"
```

(Leave the `PARTUUID=...` value exactly as the script already has it.) You'll
drop to a root prompt. From there you can try:

```bash
aether-labmode status        # Lab Mode state
nft list ruleset             # firewall rules
cat /etc/os-release          # confirm it's AETHER / Debian trixie arm64
ls /usr/bin | grep -E 'pcmanfm|mpv|fuzzel'   # the apps are installed
```

Remember: even here the **graphical desktop won't start** (no GPU in QEMU).

---

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `machine type 'raspi4b' is not supported` | QEMU older than 9.1 — update it (Step 1). |
| `qemu-system-aarch64 ... not recognized` | QEMU not on PATH — see Step 2. |
| Boots then reboots over and over | Expected first-boot loop (see above). Use `init=/bin/bash` for a shell. |
| Window is black / no desktop | Expected — `raspi4b` has no GPU. Desktop only shows on real hardware. |
| No internet inside the VM | Expected — `raspi4b` networking usually doesn't emulate. |
| Want to prove the image is really fine | Flash it to an SD card with Raspberry Pi Imager and boot a real Pi 4. |

---

## The short version

```powershell
# one time
#   install QEMU 9.1+ from qemu.org/download  (Windows)

cd C:\Users\evanc\aether-out
.\run-vm.cmd
#   watch the boot log; Ctrl+C or close the window to stop
```

The desktop you designed is for the **real Pi 4**. QEMU here is just to confirm
the OS boots and the system is intact.
