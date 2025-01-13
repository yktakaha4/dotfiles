#!/usr/bin/env bash

set -euo pipefail

base_dir="$(cd "$(dirname "$0")"; pwd)"
install_dir=${DOTFILES_INSTALL_DIR:-"$HOME/.dotfiles"}

echo "--- directories ---"
echo "base   : $base_dir"
echo "install: $install_dir"

if [ ! -e "$install_dir" ]; then
  ln -s "$base_dir" "$install_dir"
  echo "link: $base_dir => $install_dir"
fi

. "$base_dir/.helper.zsh"
. "$base_dir/.zprofile"

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
EOF

echo "done."
