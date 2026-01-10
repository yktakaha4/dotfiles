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

while read typ dname sname;
do
  if [ -z "$sname" ]; then
    src="$install_dir/$dname"
  else
    src="$install_dir/$sname"
  fi
  dst="$HOME/$dname"
  if [ -e "$dst" ]; then
    echo "$dname: already exists"
  elif [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    if [ "$typ" = "cp" ]; then
      rm -rvf "$dst"
      cp -pr "$src" "$dst"
      echo "$dname: copy files"
    elif [ "$typ" = "ln" ]; then
      ln -s "$src" "$dst"
      echo "$dname: create symlink"
    else
      echo "invalid type: $typ"
      exit 1
    fi
  else
    echo "$dname: source file not found in $base_dir"
    exit 1
  fi
done << EOF
ln .zprofile
ln .zshrc
ln .gitconfig
ln .gitignore_global
ln .tmux.conf
ln .vimrc
ln .claude/CLAUDE.md
ln .claude/settings.json
ln .codex/AGENTS.md
cp .claude/skills/task templates/agent-skills/task
cp .codex/skills/task templates/agent-skills/task
EOF

echo "done."
