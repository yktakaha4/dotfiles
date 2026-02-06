if [ -z "$DOTFILES_ZPROFILE_LOADED" ]; then
  source "$HOME/.zprofile"
fi

# --- options ---

autoload -Uz compinit add-zsh-hook
if d_skip_ci; then
  compinit
fi

bindkey -e

setopt \
  hist_ignore_all_dups \
  hist_expire_dups_first \
  hist_ignore_dups \
  hist_save_no_dups \
  share_history \
  prompt_subst \
  ignoreeof \
  auto_cd \
  auto_pushd \
  pushd_ignore_dups

export EDITOR=vim
export PAGER=less
export AWS_PAGER=""

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

export PATH="$PATH:$HOME/bin"

# --- aliases ---
alias h='print -z -- "$(history -$HISTSIZE | sort -nr | peco | sed -E "s/^ *[0-9]+ *//")"'

alias g='git'

alias ls='ls --color'
alias ll='ls -l'
alias la='ls -la'
alias l='ll'

alias less='less -R'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias tf='terraform'
alias tfp='terraform plan -no-color | grep --line-buffered -E "^\S+|^\s{,2}(\+|-|~|-/\+) |^\s<=|^Plan"'

alias k='kubectl'
alias kl='kubectl logs --max-log-requests 10 --tail=10000000 --timestamps --ignore-errors --prefix'
alias kgpo='kubectl get po -o wide'
alias kgno='kubectl get no -o wide'
alias kgnos='kubectl get nodes -o "custom-columns=NODE:.metadata.name,CREATED:.metadata.creationTimestamp,TYPE:.metadata.labels.type,AVAIL_ZONE:.metadata.labels.topology\.kubernetes\.io/zone,INSTANCE_TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,STORAGE:.status.capacity.ephemeral-storage,INSTANCE_ID:spec.providerID" | sed "s@aws://.\+/@@g"'
alias kgnosw='kubectl get nodes -w -o "custom-columns=NODE:.metadata.name,CREATED:.metadata.creationTimestamp,TYPE:.metadata.labels.type,AVAIL_ZONE:.metadata.labels.topology\.kubernetes\.io/zone,INSTANCE_TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,STORAGE:.status.capacity.ephemeral-storage,INSTANCE_ID:spec.providerID" | sed "s@aws://.\+/@@g"'
alias krno='kubectl resource-capacity --util --pod-count | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'
alias krpo='kubectl resource-capacity --util --pod-count --pods | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'
alias krco='kubectl resource-capacity --util --pod-count --containers | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'
alias krew='kubectl krew'

alias kindup='kind create cluster --config "$DOTFILES_BASE_PATH/templates/kind.yaml" --wait 5m'
alias kindown='kind delete cluster'

kgrnos() {
  tmp1="$(mktemp)"
  tmp2="$(mktemp)"
  kgnos > "$tmp1"
  krno > "$tmp2"
  join -a1 -j1 "$tmp1" "$tmp2" | column -t
}

kgpobyno() {
  kubectl get po --field-selector "spec.nodeName=$1" "${@:2}"
}

alias dcu='docker compose up -d --remove-orphans'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=10'
alias dcp='docker compose ps'
alias dcx='docker compose exec'
alias dcr='docker compose restart'
alias docker-compose='docker compose'

dcul() {
  dcu "$@" && dcl
}

alias myip='curl https://ifconfig.me/all'

alias iam='aws sts get-caller-identity --query Arn --output text'
# shellcheck disable=SC2154
alias aws2fa='echo -n "caller identity: $(iam)\nmfa serial: $(printenv AWS_MFA_SERIAL)\nenter token: " && read token && source <(aws sts get-session-token --token-code "$token" --serial-number "$(printenv AWS_MFA_SERIAL)" | jq -r ".Credentials | [\"export AWS_ACCESS_KEY_ID=\(.AccessKeyId)\", \"export AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey)\",\"export AWS_SESSION_TOKEN=\(.SessionToken)\", \"echo Expiration: \(.Expiration)\"] | @tsv" | tr "\t" "\n")'

alias giam='gcloud config list account --format text'

alias editorconfig='cat "$DOTFILES_BASE_PATH/templates/.editorconfig"'
alias makefile='cat "$DOTFILES_BASE_PATH/templates/Makefile"'
alias copilot_instructions='cat $DOTFILES_BASE_PATH/templates/copilot-instructions.md'
alias docs='cat $DOTFILES_BASE_PATH/docs/README.md'
alias dupdate='$DOTFILES_BASE_PATH/update.sh'

# shellcheck disable=SC2154
alias colorpallet='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done'

queryfile() {
  fname="$1"
  opts="-table"
  separator=''

  case "$fname" in
  *\.tsv)
    separator='\t'
    ;;
  *\.csv)
    separator=','
    ;;
  esac

  if [[ -n "$separator" ]]
  then
    dbfile="$(mktemp)"
    table_name="file"
    sqlite3 -separator "$separator" "$dbfile" ".import $fname $table_name"
    sqlite3 $opts "$dbfile" "pragma table_info('file');"
    fname="$dbfile"
  fi

  sqlite3 $opts "$fname"
}

# --- settings ---

add-zsh-hook precmd d_precmd
add-zsh-hook preexec d_preexec

if d_exists "$DOTFILES_BASE_PATH/.zshrc.$(d_os)"; then
  source "$DOTFILES_BASE_PATH/.zshrc.$(d_os)"
fi

if d_wsl; then
  source "$DOTFILES_BASE_PATH/.zshrc.wsl"
fi

if d_exists "$DOTFILES_BASE_PATH/.zshrc.ignore"; then
  source "$DOTFILES_BASE_PATH/.zshrc.ignore"
fi

if d_require git; then
  # shellcheck disable=SC2034
  PROMPT='$(d_prompt)'
fi

if d_require tmux; then
  if tmux info >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf"
  fi
fi

if d_require direnv; then
  eval "$(direnv hook zsh)"
fi

if d_require mise; then
  eval "$(mise activate zsh)"
fi

export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
if d_require goenv; then
  eval "$(goenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if d_require pyenv; then
  eval "$(pyenv init - zsh)"
fi

export PATH="$HOME/.nodenv/bin:$PATH"
if d_require nodenv; then
  eval "$(nodenv init - zsh)"
fi

export PATH="$HOME/.rbenv/bin:$PATH"
if d_require rbenv; then
  eval "$(rbenv init -)"
fi

export PATH="$HOME/.tfenv/bin:$PATH"

if d_require kubectl; then
  if d_skip_ci; then
    source <(kubectl completion zsh)
  fi
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
fi

export PATH="$HOME/.cargo/bin:$PATH"
if d_require "$HOME/.cargo/env"; then
  source "$HOME/.cargo/env"
fi

export PATH="$HOME/.local/bin:$PATH"
if d_exists "$HOME/.local/bin/env"; then
  source "$HOME/.local/bin/env"
fi

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# --- for debugging ---
if d_debug; then
  zprof
  set +x
fi
# --- for debugging ---
