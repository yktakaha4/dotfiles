base_path="$(cd "$(dirname "$0")" || exit; pwd)"
export DOTFILES_BASE_PATH="$base_path"

d_debug() {
  test -f "$HOME/.dotfiles_debug"
}

d_require() {
  which "$@" >/dev/null
}

d_exists() {
  ls "$@" >/dev/null
}

d_os() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

d_now_ms() {
  if [ "$(d_os)" = "darwin" ]; then
    date "+%s000"
  else
    date "+%s%3N"
  fi
}

d_preexec() {
  DOTFILES_EXEC_TIME_START="$(d_now_ms)"
}

d_precmd() {
  DOTFILES_RETURN_CODE="$?"
  DOTFILES_EXEC_TIME_NOW="$(d_now_ms)"
  DOTFILES_EXEC_TIME="$(echo "scale=1; ($DOTFILES_EXEC_TIME_NOW - ${DOTFILES_EXEC_TIME_START:-"$DOTFILES_EXEC_TIME_NOW"}) / 1000" | bc)s"
  DOTFILES_EXEC_TIME_START=""
}

d_prompt() {
  rc="$DOTFILES_RETURN_CODE"
  dir="%~"
  branch=""
  mark_diff=""
  mark_fetch=""

  if [ "$rc" = "0" ]; then
    rc=""
  fi

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)"
    git_status="$(git status --porcelain 2>/dev/null)"
    if [ -z "$git_status" ]; then
      mark_diff=""
    else
      staged=""
      unstaged=""
      untracked=""

      if echo "$git_status" | grep -m1 -q '^[ACDMRTUXB]'; then
        staged="+"
      fi

      if echo "$git_status" | grep -m1 -q '^.M\|^..M'; then
        unstaged="*"
      fi

      if echo "$git_status" | grep -m1 -q '^??'; then
        untracked="?"
      fi

      mark_diff="$staged$unstaged$untracked"
    fi

    rev_parse_local="$(git rev-parse @ 2>/dev/null)"
    # shellcheck disable=SC1083
    rev_parse_remote="$(git rev-parse @{u} 2>/dev/null)"
    if [ "$rev_parse_local" = "$rev_parse_remote" ]; then
      mark_fetch=""
    elif [ -z "$rev_parse_remote" ]; then
      mark_fetch="→"
    else
      # shellcheck disable=SC1083
      rev_parse_base="$(git merge-base @ @{u} 2>/dev/null)"
      if [ "$rev_parse_local" = "$rev_parse_base" ]; then
        mark_fetch="↓"
      elif [ "$rev_parse_remote" = "$rev_parse_base" ]; then
        mark_fetch="↑"
      else
        mark_fetch="↓↑"
      fi
    fi
  fi

  mark="$mark_diff$mark_fetch"
  time="$DOTFILES_EXEC_TIME"

  first="%F{8}${dir}${branch:+ $branch}%F{3}${mark:+ $mark}%F{8}${time:+ $time}%F{1}${rc:+ ($rc)}"
  second="%f$ "
  echo "
${first}
${second}"
}
