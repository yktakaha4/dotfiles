#!/usr/bin/env zsh

set -euo pipefail

base_dir="$(cd "$(dirname "$0")"; pwd)"
install_dir=${DOTFILES_INSTALL_DIR:-"$HOME/.dotfiles"}

if [ "$base_dir" != "$install_dir" ]; then
  echo "invalid path: expected=$install_dir, actual=$base_dir"
  exit 1
fi

. "$base_dir/.helper.zsh"

echo "install dependencies..."

"$base_dir/install.zsh.$(d_os)"

echo "setup dotfiles..."

while read fname
do
  src="$base_dir/$fname"
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
