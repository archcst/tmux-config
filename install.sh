#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: ./install.sh [--link|--copy]

  --link  Symlink configuration files into the tmux config directory (default)
  --copy  Copy configuration files instead
EOF
}

mode=link
case "${1:-}" in
  ""|--link) ;;
  --copy) mode=copy ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 1 ;;
esac

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
target="$config_home/tmux"
plugin_dir="$target/plugins"
socket="tmux-config-install-$$"
timestamp=$(date +%Y%m%d%H%M%S)

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

backup_existing() {
  path=$1
  backup="$path.backup.$timestamp"
  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$backup.1"
  done
  mv "$path" "$backup"
  echo "Backed up: $path -> $backup"
}

# Replace the legacy whole-directory symlink, but preserve regular config dirs.
if [ -L "$target" ] || { [ -e "$target" ] && [ ! -d "$target" ]; }; then
  backup_existing "$target"
fi
mkdir -p "$target"

install_entry() {
  name=$1
  source=$repo_dir/$name
  destination=$target/$name

  if [ "$mode" = link ] && [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
    echo "Already linked: $destination"
    return
  fi

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    backup_existing "$destination"
  fi

  if [ "$mode" = link ]; then
    ln -s "$source" "$destination"
    echo "Linked: $destination -> $source"
  else
    cp -R "$source" "$destination"
    echo "Copied: $source -> $destination"
  fi
}

install_entry tmux.conf
install_entry tmux.keymap.conf
install_entry tmux.local.conf.example
install_entry scripts

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
echo "Tmux configuration installed successfully using $mode mode."
echo "Run 'tmux' to start. Optional overrides: $target/tmux.local.conf"
