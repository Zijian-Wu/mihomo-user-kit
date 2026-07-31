# Mihomo User Kit

[简体中文](README_zh-CN.md)

A user-level Mihoro/Mihomo setup for **headless Linux environments without sudo or a usable user systemd session**. Mihomo runs in tmux, and all managed files stay under the current user's home directory.

## Requirements

- Linux with write access to your own `$HOME`;
- `bash`, `curl`, `tar`, `tmux`, and common coreutils;
- No sudo access is required, but an administrator must install missing packages;
- A Mihomo/Clash subscription URL.

## One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/Zijian-Wu/mihomo-user-kit/main/install.sh | bash
```

Then initialize and start Mihomo:

```bash
mihoro init
mihomo-tmux start
```

Or install from a clone:

```bash
git clone https://github.com/Zijian-Wu/mihomo-user-kit.git
cd mihomo-user-kit
bash install.sh
```

## Default behavior

- Writes only to `~/.local/bin` and `~/.config/mihomo`;
- Never runs `sudo`, a system package manager, `systemctl`, or configures boot startup;
- Reports missing dependencies without attempting privilege escalation;
- Does not overwrite an existing Mihoro installation;
- Installs only by default: no initialization and no proxy startup;
- Links `~/.config/mihoro.toml` to `~/.config/mihomo/mihoro.toml` for centralized configuration;
- Uses tmux so Mihomo survives SSH disconnects.

Installer options:

```bash
bash install.sh --help
bash install.sh --check
bash install.sh --enable-codex
bash install.sh --init
```

## One-line uninstall

Remove only this kit's commands and shell hooks while keeping Mihoro, Mihomo, the subscription, and configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/Zijian-Wu/mihomo-user-kit/main/uninstall.sh | bash
```

Permanently delete all user-level Mihoro/Mihomo files and configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/Zijian-Wu/mihomo-user-kit/main/uninstall.sh | bash -s -- --purge --yes
```

## Commands

| Command | Purpose |
|---|---|
| `mihomo-tmux --help` | Start, inspect, attach, restart, or stop Mihomo |
| `with-mihomo --help` | Proxy one command without changing the parent shell |
| `mihomo-update-geodata --help` | Update and normalize GeoSite/GeoIP files |
| `mihomo-normalize-geodata --help` | Normalize GeoData filenames and symlinks only |
| `mihoro --help` | Show native Mihoro commands |
| `bash uninstall.sh --help` | Show safe removal and purge options |

Common operations:

```bash
mihomo-tmux start
mihomo-tmux status
mihomo-tmux logs
mihomo-tmux attach
mihomo-tmux restart
mihomo-tmux stop

# Proxy variables in the current shell
eval "$(mihoro proxy export)"
eval "$(mihoro proxy unset)"

# Proxy one command only
with-mihomo curl -I https://github.com
with-mihomo git clone https://github.com/owner/repository.git
with-mihomo codex
```

## GeoData

Mihoro downloads lowercase `geosite.dat`/`geoip.dat`, while Mihomo uses the canonical names `GeoSite.dat`/`GeoIP.dat`. This kit normalizes the filenames and keeps lowercase symlinks for future Mihoro updates.

To update DAT files, set this under `[mihomo_config]` in `~/.config/mihomo/mihoro.toml`:

```toml
geodata_mode = true
```

Then run:

```bash
mihomo-update-geodata
```

Coverage depends on the configured `geox_url`, not filename capitalization. Mihoro's default URL points to the full `geosite.dat` from MetaCubeX `meta-rules-dat`.

## File layout

```text
~/.local/bin/                 # mihoro, mihomo, and kit commands
~/.config/mihomo/
├── mihoro.toml               # Mihoro config and subscription URL
├── config.yaml               # Mihomo config
├── GeoSite.dat / GeoIP.dat
├── geosite.dat / geoip.dat   # compatibility symlinks
├── country.mmdb
├── ui/
└── shell/codex-proxy.sh      # optional

~/.config/mihoro.toml -> ~/.config/mihomo/mihoro.toml
```

> `mihoro.toml` may contain a private subscription URL. Never commit it to GitHub.

## Limitations and troubleshooting

Mihoro's native `start/status/stop/restart/apply` commands and parts of its core update flow depend on user systemd. This kit uses `mihomo-tmux` for process management instead. After a server reboot, run `mihomo-tmux start` again.

If `mihoro init` fails at the final systemd/DBus step but these checks pass, start Mihomo with tmux:

```bash
test -x ~/.local/bin/mihomo
test -f ~/.config/mihomo/config.yaml
mihomo-tmux start
```

Validate or run Mihomo in the foreground:

```bash
~/.local/bin/mihomo -t -d ~/.config/mihomo
~/.local/bin/mihomo -d ~/.config/mihomo
```

## License

MIT
