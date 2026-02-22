base_path="$(cd "$(dirname "$0")" || exit; pwd)"
export DOTFILES_BASE_PATH="$base_path"

d_debug() {
  test -f "$HOME/.dotfiles_debug"
}

d_skip_ci() {
  test -z "${DOTFILES_IS_CI:-}"
}

d_require() {
  which "$@" >/dev/null 2>&1 || return 1
}

d_exists() {
  ls "$@" >/dev/null 2>&1 || return 1
}

d_os() {
  uname -s | tr '[:upper:]' '[:lower:]'
}

d_arch() {
  uname -m | sed 's/aarch64/arm64/'
}

d_wsl() {
  d_require clip.exe
}

d_datetime() {
  date +%Y-%m-%dT%H:%M:%S
}

d_now_ms() {
  if [ "$(d_os)" = "darwin" ]; then
    if d_require perl; then
      perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000)'
    else
      date "+%s000"
    fi
  else
    date "+%s%3N"
  fi
}

d_epoch_to_ms() {
  start="${1:-$2}"
  end="${2:-$1}"
  if [ "$start" -gt "$end" ] 2>/dev/null; then
    start="$end"
  fi
  echo "$start $end" | awk '{printf("%.1fs\n",($2-$1)/1000)}'
}

d_preexec() {
  DOTFILES_EXEC_TIME_START="$(d_now_ms)"
}

d_precmd() {
  DOTFILES_RETURN_CODE="$?"
  DOTFILES_EXEC_DATETIME="$(d_datetime)"
  DOTFILES_EXEC_TIME_NOW="$(d_now_ms)"
  DOTFILES_EXEC_TIME="$(d_epoch_to_ms "$DOTFILES_EXEC_TIME_START" "$DOTFILES_EXEC_TIME_NOW")"
  DOTFILES_EXEC_TIME_START=""

  DOTFILES_KUBE_CONTEXT=""
  if d_require kubectl; then
    kube_mark="⎈"
    DOTFILES_KUBE_CONTEXT="$(kubectl config view --minify --output="jsonpath=$kube_mark:{..current-context}:{..namespace}" 2>/dev/null)"
  fi
}

d_prompt() {
  branch=""
  mark_diff=""
  mark_fetch=""

  rc="$DOTFILES_RETURN_CODE"
  if [ "$rc" = "0" ]; then
    rc=""
  fi

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git branch --contains | awk '{gsub(/^\* /, "");print $0}' 2>/dev/null)"
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

      if echo "$git_status" | grep -m1 -q '^.[ACDMRTUXB]\|^..[ACDMRTUXB]'; then
        unstaged="*"
      fi

      if echo "$git_status" | grep -m1 -q '^??'; then
        untracked="?"
      fi

      mark_diff="$staged$unstaged$untracked"
    fi

    unpushed=""
    unpulled=""
    if [ -n "$(git log --oneline "origin/$branch..$branch" 2>/dev/null | head -1)" ]; then
      unpushed="↑"
    elif [ -z "$(git branch -r 2>/dev/null | grep -m1 "$branch")" ]; then
      unpushed="→"
    fi

    if [ -n "$(git log --oneline "$branch..origin/$branch" 2>/dev/null | head -1)" ]; then
      unpulled="↓"
    fi
    mark_fetch="$unpushed$unpulled"
  fi

  dir="%~"
  mark="$mark_diff$mark_fetch"
  dt="$DOTFILES_EXEC_DATETIME"
  time="$DOTFILES_EXEC_TIME"
  kube="$DOTFILES_KUBE_CONTEXT"

  first="%F{8}${dir}${branch:+ $branch}%F{3}${mark:+ $mark}%F{4}${kube:+ $kube}%F{8}${dt:+ $dt}${time:+ $time}%F{1}${rc:+ ($rc)}"
  second="%f$ "
  echo "
${first}
${second}"
}
