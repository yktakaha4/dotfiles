#!/usr/bin/env bash

set -euo pipefail

base_dir="$(cd "$(dirname "$0")"; pwd)"
install_dir=${DOTFILES_INSTALL_DIR:-"$HOME/.dotfiles"}

. "$base_dir/.helper.sh"

echo "--- directories ---"
echo "os     : $(d_os)"
echo "base   : $base_dir"
echo "install: $install_dir"

if [ ! -e "$install_dir" ]; then
  ln -s "$base_dir" "$install_dir"
  echo "link: $base_dir => $install_dir"
fi

echo "--- install dependencies ---"

"$base_dir/install.sh.$(d_os)"

echo "--- setup dotfiles ---"

while read fname
do
  src="$install_dir/$fname"
  dst="$HOME/$fname"
  if [ -e "$dst" ]; then
    echo "$fname: already exists"
  elif [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "$fname: create symlink"
  else
    echo "$fname: source file not found in $base_dir"
  fi
done << EOF
.zprofile
.zshrc
.gitconfig
.gitignore_global
.tmux.conf
.vimrc
.claude/CLAUDE.md
.claude/settings.json
.claude/commands
.claude/skills
.codex/AGENTS.md
.codex/skills
EOF

echo "done."
