# Optional Codex wrapper.
# Proxy variables live in a subshell and disappear when Codex exits.
codex() (
  local manager="${MIHOMO_TMUX_BIN:-$HOME/.local/bin/mihomo-tmux}"
  local mihoro="${MIHORO_CLI:-$HOME/.local/bin/mihoro}"

  if ! type -P codex >/dev/null 2>&1; then
    echo "Codex CLI was not found in PATH." >&2
    return 127
  fi

  if [[ ! -x "$manager" ]]; then
    echo "mihomo-tmux not found or not executable: $manager" >&2
    return 1
  fi

  if [[ ! -x "$mihoro" ]]; then
    echo "Mihoro not found or not executable: $mihoro" >&2
    return 1
  fi

  "$manager" start >/dev/null || return 1
  eval "$("$mihoro" proxy export)"
  command codex "$@"
)
