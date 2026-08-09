#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
source_dir="$repo_dir/.config/tmux"
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
target="$config_home/tmux"
backup=""
socket="tmux-config-install-$$"

cleanup() {
  tmux -L "$socket" kill-server >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

for command in tmux git; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Error: required command not found: $command" >&2
    exit 1
  fi
done

if ! command -v fzf >/dev/null 2>&1; then
  echo "Warning: fzf is not installed; tmux-fzf-url will not work." >&2
fi

mkdir -p "$config_home"

same_target=false
if [ -d "$target" ] && [ "$(CDPATH= cd -- "$target" && pwd -P)" = "$source_dir" ]; then
  same_target=true
fi

if [ "$same_target" = false ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$backup.1"
  done
  mv "$target" "$backup"
  echo "Backed up existing configuration to: $backup"
fi

if [ "$same_target" = false ]; then
  ln -s "$source_dir" "$target"
  echo "Linked: $target -> $source_dir"
else
  echo "Configuration is already linked: $target"
fi

plugin_dir="$target/plugins"
if [ ! -x "$plugin_dir/tpm/tpm" ]; then
  mkdir -p "$plugin_dir"
  git clone https://github.com/tmux-plugins/tpm "$plugin_dir/tpm"
fi

# Use an isolated server so installation does not alter existing tmux sessions.
tmux -L "$socket" -f /dev/null new-session -d -s plugin-install
tmux -L "$socket" set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_dir/"
tmux_env=$(tmux -L "$socket" display-message -p '#{socket_path},#{pid},0')
TMUX="$tmux_env" "$plugin_dir/tpm/bin/install_plugins"

echo
echo "Tmux configuration installed successfully."
echo "Run 'tmux' to start. Optional overrides: $target/tmux.local.conf"
