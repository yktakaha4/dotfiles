#!/usr/bin/env bash

set -euo pipefail

base_dir="$(cd "$(dirname "$0")"; pwd)"
install_dir=${DOTFILES_INSTALL_DIR:-"$HOME/.dotfiles"}
target_dir=${DOTFILES_TARGET_DIR:-"$HOME"}
skip_install_deps=${DOTFILES_SKIP_INSTALL_DEPS:-""}

. "$base_dir/.helper.sh"

echo "--- directories ---"
echo "os     : $(d_os)"
echo "base   : $base_dir"
echo "install: $install_dir"
echo "target : $target_dir"

if [ ! -e "$install_dir" ]; then
  ln -s "$base_dir" "$install_dir"
  echo "link: $base_dir => $install_dir"
fi

echo "--- install dependencies ---"

if [ -z "$skip_install_deps" ]; then
  "$base_dir/install_deps.$(d_os).sh"
else
  echo "install dependencies: skipped."
fi

echo "--- setup dotfiles ---"

while read typ dname sname;
do
  if [ -z "$sname" ]; then
    src="$install_dir/$dname"
  else
    src="$install_dir/$sname"
  fi
  dst="$target_dir/$dname"
  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$dst")"
    if [ "$typ" = "cp" ]; then
      if [ -e "$dst" ]; then
        echo "$dname: remove existing files"
        rm -rf "$dst"
      fi
      echo "$dname: copy files"
      cp -pr "$src" "$dst"
      if [ -d "$dst" ]; then
        touch "$dst/.managed_by_dotfiles"
      fi
    elif [ "$typ" = "ln" ]; then
      if [ -e "$dst" ]; then
        echo "$dname: already exists"
      else
        echo "$dname: create symlink"
        ln -s "$src" "$dst"
      fi
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
