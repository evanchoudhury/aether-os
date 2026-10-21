# AETHER OS — Lab Mode privacy (Tor + VPN kill-switch)

Lab Mode is a two-state switch. **SAFE** is a normal, hardened daily driver.
**ARMED** turns the box into an anonymized research machine.

## What ARMED does

1. **Starts Tor** (runs as the `debian-tor` user, SOCKS proxy on `127.0.0.1:9050`).
2. **Applies the kill-switch** (`research.nft`): outbound is default-**drop**. The
   only things allowed to leave are loopback (apps → Tor's SOCKS), the Tor daemon
   itself, an active WireGuard tunnel, and the VPN handshake. **Everything else —
   ordinary apps and any direct DNS — is dropped.** If Tor or the VPN drops,
   traffic stops instead of falling back to the clear. No leak.
3. **Brings up the VPN** if one is configured (see below): **VPN → Tor**.
4. The **Anonymous Browser** (Tor Browser) becomes usable, including `.onion`
   (dark web) sites. It refuses to open in SAFE mode.

## What SAFE does

Stops Tor, brings the VPN down, restores the everyday firewall. Normal internet;
`.onion` and the Anonymous Browser are unreachable.

## Enabling the VPN layer

Copy a WireGuard config from your provider (Mullvad / IVPN / Proton / your own
server) to `/etc/aether/vpn/aether.conf`. The **Endpoint must be a numeric
`IP:port`** — the kill-switch blocks direct DNS, so a hostname can't be resolved,
and numeric-only is also what lets `lab-arm` safely allow the handshake. A template
lives at `/etc/aether/vpn/aether.conf.example`.

## How the privilege boundary works

`aether-labmode arm|disarm` (unprivileged) is the only place an argument is
parsed. It calls `pkexec /usr/libexec/aether/lab-{arm,disarm}` — fixed,
**argument-free** root scripts behind a Polkit policy. No GUI runs as root, and
no user input reaches a root shell. The VPN endpoint read from the config is
validated to digits-and-dots before it is used.

## Honest limits — read this

- **This is strong anonymity, not "untraceable."** Tor + VPN hides your IP and
  your ISP's view, but de-anonymization still happens via **browser
  fingerprinting**, **traffic correlation**, **malware**, or **user error** (e.g.
  logging into a real account over Tor). Use **Tor Browser** (shipped), not a
  normal browser, and don't tie anonymous sessions to your identity.
- **`.onion` is slow on the first hop** (circuit + descriptor fetch). Normal.
- **Legal/ethical:** Tor and `.onion` are legal privacy technology. Lab Mode keeps
  the *use* authorized via the scope model — this is for privacy, research, and
  authorized testing, not for crime.
- **The kill-switch needs real hardware.** It is enforced by nftables on the Pi.
  In the WSL preview (NAT'd networking) Tor works but the kill-switch is not
  enforced — never rely on WSL for leak-proofing.
