#!/usr/bin/env bash
set -euo pipefail

LOCAL_BIN="$HOME/.local/bin"
CONFIG_ROOT="${MIHOMO_CONFIG_DIR:-$HOME/.config/mihomo}"
DEFAULT_MIHORO_CONFIG="$HOME/.config/mihoro.toml"
USER_SYSTEMD_UNIT="$HOME/.config/systemd/user/mihomo.service"
SESSION="${MIHOMO_TMUX_SESSION:-mihomo}"
PURGE=0
ASSUME_YES=0

usage() {
  cat <<'USAGE'
Usage: bash uninstall.sh [options]

Default behavior:
  - Stops the tmux-managed Mihomo process when possible.
  - Removes only commands and shell hooks installed by mihomo-user-kit.
  - Keeps Mihoro, Mihomo, the subscription URL, and all proxy configuration.

Options:
  --purge        Also remove Mihoro, Mihomo, GeoData, UI, and all configuration
  -y, --yes      Skip the confirmation required by --purge
  -h, --help     Show this help

Environment:
  MIHOMO_CONFIG_DIR      Config directory (default: ~/.config/mihomo)
  MIHOMO_TMUX_SESSION    tmux session name (default: mihomo)

This script never runs sudo, a system package manager, or systemctl.
USAGE
}

while (( $# > 0 )); do
  case "$1" in
    --purge) PURGE=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

remove_exact_line() {
  local file="$1"
  local line="$2"
  local temp_file

  [[ -f "$file" ]] || return 0
  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    return 0
  fi

  temp_file="$(mktemp)"
  grep -vxF "$line" "$file" > "$temp_file" || true
  cat "$temp_file" > "$file"
  rm -f -- "$temp_file"
}

if command -v tmux >/dev/null 2>&1 && tmux has-session -t "=$SESSION" 2>/dev/null; then
  tmux kill-session -t "=$SESSION" || true
  echo "Stopped tmux session: $SESSION"
fi

for command_name in \
  mihomo-tmux \
  with-mihomo \
  mihomo-normalize-geodata \
  mihomo-update-geodata \
  mihomo-set-user-agent; do
  rm -f -- "$LOCAL_BIN/$command_name"
done

CODEX_PROXY="$CONFIG_ROOT/shell/codex-proxy.sh"
CODEX_SOURCE_LINE="source \"$CODEX_PROXY\""
remove_exact_line "$HOME/.bashrc" "$CODEX_SOURCE_LINE"
remove_exact_line "$HOME/.zshrc" "$CODEX_SOURCE_LINE"
rm -f -- "$CODEX_PROXY"
rmdir "$CONFIG_ROOT/shell" 2>/dev/null || true

echo "Removed mihomo-user-kit commands and optional shell hooks."

if (( ! PURGE )); then
  cat <<'KEPT'
Kept Mihoro, Mihomo, subscription, GeoData, UI, and configuration.
Use --purge only when you intentionally want to delete all user-level data.
KEPT
  exit 0
fi

if (( ! ASSUME_YES )); then
  if [[ ! -t 0 ]]; then
    echo "--purge requires --yes when standard input is not interactive." >&2
    exit 2
  fi

  cat <<WARNING
This will permanently remove:
  $LOCAL_BIN/mihoro
  $LOCAL_BIN/mihomo
  $CONFIG_ROOT
  $DEFAULT_MIHORO_CONFIG
  $USER_SYSTEMD_UNIT

The subscription URL and all local proxy configuration will be deleted.
WARNING
  read -r -p "Type 'purge' to continue: " answer
  if [[ "$answer" != "purge" ]]; then
    echo "Purge cancelled."
    exit 1
  fi
fi

rm -f -- "$LOCAL_BIN/mihoro" "$LOCAL_BIN/mihomo"
rm -rf -- "$CONFIG_ROOT"
rm -f -- "$DEFAULT_MIHORO_CONFIG"
rm -f -- "$USER_SYSTEMD_UNIT"
rmdir "$HOME/.config/systemd/user" 2>/dev/null || true
rmdir "$HOME/.config/systemd" 2>/dev/null || true

echo "Purged Mihoro, Mihomo, and all user-level configuration managed by this setup."
echo "The ~/.local/bin PATH entry was preserved because other user commands may use it."
