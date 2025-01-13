# --- options ---

autoload -Uz compinit add-zsh-hook
compinit

setopt \
  histignorealldups \
  sharehistory \
  prompt_subst \
  ignoreeof \
  auto_cd \
  auto_pushd \
  pushd_ignore_dups

export EDITOR=vim
export PAGER=less

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# --- aliases ---

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

alias iam='aws sts get-caller-identity --query Arn --output text'

alias editorconfig='cat "$DOTFILES_BASE_PATH/templates/.editorconfig"'
alias makefile='cat "$DOTFILES_BASE_PATH/templates/Makefile"'

# shellcheck disable=SC2154
alias colorpallet='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done'

# --- settings ---

add-zsh-hook precmd d_precmd
add-zsh-hook preexec d_preexec

if d_exists "$DOTFILES_BASE_PATH/.zshrc.$(d_os)"; then
  . "$DOTFILES_BASE_PATH/.zshrc.$(d_os)"
fi

if d_require git; then
  # shellcheck disable=SC2034
  PROMPT='$(d_prompt)'
fi

if d_require tmux; then
  if d_skip_ci; then
    tmux source-file "$HOME/.tmux.conf"
  fi
fi

if d_require direnv; then
  eval "$(direnv hook zsh)"
fi

if d_require goenv; then
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
fi

if d_require pyenv; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

if d_require rbenv; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

if d_require kubectl; then
  source <(kubectl completion zsh)
fi

if d_require cargo; then
  . "$HOME/.cargo/env"
fi

# --- for debugging ---
if d_debug; then
  zprof
  set +x
fi
# --- for debugging ---
