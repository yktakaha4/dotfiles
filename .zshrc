# options

setopt histignorealldups sharehistory prompt_subst ignoreeof auto_cd auto_pushd pushd_ignore_dups no_flow_control
bindkey -e

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# env
export PATH="$HOME/.dotfiles/bin:$PATH"
export EDITOR="vim"
export PAGER="less"

# local/bin
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# Set up the prompt

autoload -Uz promptinit && promptinit
autoload -Uz colors && colors
autoload -Uz add-zsh-hook vcs_info

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{green}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats " %c%u%b"
zstyle ':vcs_info:*' actionformats ' %c%u%b[%a]'

function check_commits() {
  PROMPT_COMMITS_MARK=""

  git rev-parse --show-toplevel --quiet >/dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null)"
    if [[ "$BRANCH" != "" ]]
    then
      UP="⇡"
      DOWN="⇣"
      RIGHT="⇢"
      UNPUSHED_MARK="$(git log --oneline "origin/$BRANCH..$BRANCH" 2>/dev/null | wc -l | awk '$1>0{print "'"$UP"'"}')"
      UNPULLED_MARK="$(git log --oneline "$BRANCH..origin/$BRANCH" 2>/dev/null | wc -l | awk '$1>0{print "'"$DOWN"'"}')"
      if [[ "$UNPUSHED_MARK" = "" ]]
      then
        UNPUSHED_MARK="$(git branch -r 2>/dev/null | grep "$BRANCH" | wc -l | awk '$1==0{print "'"$RIGHT"'"}')"
      fi
      PROMPT_COMMITS_MARK="$UNPUSHED_MARK$UNPULLED_MARK"
    fi
  fi
}

function precmd() {
  print ""
}

function precmd_prompt() {
  vcs_info
  check_commits
  PROMPT_EXEC_TIME_NOW="$(date +%s%3N)"
  PROMPT_EXEC_TIME="$(echo "scale=1; ($PROMPT_EXEC_TIME_NOW - ${PROMPT_EXEC_TIME_START:-"$PROMPT_EXEC_TIME_NOW"}) / 1000" | bc)s"
}
function preexec_prompt() {
  PROMPT_EXEC_TIME_START="$(date +%s%3N)"
}
add-zsh-hook precmd precmd_prompt
add-zsh-hook preexec preexec_prompt

PROMPT='%F{blue}%~%f%F{008}${VIRTUAL_ENV+" ($(basename "$VIRTUAL_ENV"))"}%f $(kube_ps1)%F{008}$vcs_info_msg_0_%F{cyan}$PROMPT_COMMITS_MARK%f%(?..%F{red} (%?%))%f %F{008}$PROMPT_EXEC_TIME%f %F{yellow}%*%f
%(?.%F{magenta}.%F{red})$%f '

# Keep lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE="100000"
SAVEHIST="100000"
HISTFILE="$HOME/.zsh_history"

# syntax-highliting
if [[ -f "$HOME/.dotfiles/submodules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]
then
  source "$HOME/.dotfiles/submodules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/highlighters/main/main-highlighter.zsh
  ZSH_HIGHLIGHT_STYLES[arg0]="fg=blue"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=012,underline"
  ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=012,underline"
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=012"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=012"
fi

# autosuggestions
if [[ -f "$HOME/.dotfiles/submodules/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]
then
  source "$HOME/.dotfiles/submodules/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# alias
alias vzrc='vim ~/.zshrc'
alias .zrc='. ~/.zshrc'

alias ls='ls --color'
alias ll='ls -l'
alias la='ls -la'
alias l='ll'

alias less='less -R'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias .='source'

alias lgrep='grep --line-buffered'

alias tf='terraform'
alias tfp='terraform plan -no-color | grep --line-buffered -E "^\S+|^\s{,2}(\+|-|~|-/\+) |^\s<=|^Plan"'

alias pbvim="pbpaste | pvim | pbcopy"

alias colorpallet='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done'
alias viminstall="vim +PluginInstall +qall"

alias dcu='docker compose up -d --remove-orphans'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail=10'
alias dcp='docker compose ps'
alias dcx='docker compose exec'
alias dcr='docker compose restart'
alias docker-compose='docker compose'
function dcul() {
  dcu $@ && dcl
}

alias k='kubectl'
alias kl='kubectl logs --max-log-requests 10 --tail=10000000 --timestamps --ignore-errors --prefix'
alias km='kustomize'
alias kmd='kustomize build | kubectl diff -f -'
alias kgpo='kubectl get po -o wide'
alias kgno='kubectl get no -o wide'
alias k9s='k9s --readonly'
alias k9sw='\k9s'
alias mk='minikube kubectl --'
alias kgnos='kubectl get nodes -o "custom-columns=NODE:.metadata.name,CREATED:.metadata.creationTimestamp,TYPE:.metadata.labels.type,AVAIL_ZONE:.metadata.labels.topology\.kubernetes\.io/zone,INSTANCE_TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,STORAGE:.status.capacity.ephemeral-storage,INSTANCE_ID:spec.providerID" | sed "s@aws://.\+/@@g"'
alias kgnosw='kubectl get nodes -w -o "custom-columns=NODE:.metadata.name,CREATED:.metadata.creationTimestamp,TYPE:.metadata.labels.type,AVAIL_ZONE:.metadata.labels.topology\.kubernetes\.io/zone,INSTANCE_TYPE:.metadata.labels.node\.kubernetes\.io/instance-type,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,STORAGE:.status.capacity.ephemeral-storage,INSTANCE_ID:spec.providerID" | sed "s@aws://.\+/@@g"'
alias krno='kubectl resource-capacity --util --pod-count | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'
alias krpo='kubectl resource-capacity --util --pod-count --pods | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'
alias krco='kubectl resource-capacity --util --pod-count --containers | sed -e "s/ \(REQUESTS\|LIMITS\|UTIL\|COUNT\)/_\1/g" | sed -e "s/ (\([^)]*\))/(\1) /g"'

function kgrnos() {
  tmp1="$(mktemp)"
  tmp2="$(mktemp)"
  kgnos > "$tmp1"
  krno > "$tmp2"
  join -a1 -j1 "$tmp1" "$tmp2" | column -t
}

function kgpobyno() {
  kubectl get po --field-selector "spec.nodeName=$1" ${@:2}
}

alias editorconfig="cat $HOME/.dotfiles/.editorconfig"
alias makefile="cat $HOME/.dotfiles/.Makefile"

alias tailf="tail -f"

alias ssh="ssh -o ServerAliveInterval=60"

alias qcsv='q -b -d, -HO'

alias iam='aws sts get-caller-identity --query Arn --output text'

# rcfiles and configs

# awscli
which aws >/dev/null || (
  # https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html
  cd "$(mktemp -d)"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
)

# git
[[ -e "$HOME/.gitconfig" ]] || ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
[[ -e "$HOME/.gitignore_global" ]] || ln -s "$HOME/.dotfiles/.gitignore_global" "$HOME/.gitignore_global"

# vim
[[ -e "$HOME/.vimrc" ]] || ln -s "$HOME/.dotfiles/.vimrc" "$HOME/.vimrc"
if [[ ! -e "$HOME/.vim/bundle/Vundle.vim" ]]
then
  mkdir -p "$HOME/.vim/bundle/"
  ln -s "$HOME/.dotfiles/submodules/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim"
  vim +PluginInstall +qall
fi

# xinput
[[ -f "$HOME/.xmodmap" ]] || ln -s "$HOME/.dotfiles/.xmodmap" "$HOME/.xmodmap"
[[ -f "$HOME/.xinputrc" ]] || ln -s "$HOME/.dotfiles/.xinputrc" "$HOME/.xinputrc"

# envs
which curl >/dev/null || sudo apt-get install -y curl
which tmux >/dev/null || sudo apt-get install -y tmux
which bc >/dev/null || sudo apt-get install -y bc
which jq >/dev/null || sudo apt-get install -y jq
which make >/dev/null || sudo apt-get install -y make gcc
which unzip >/dev/null || sudo apt-get install -y unzip

# tmux
[[ -f "$HOME/.tmux.conf" ]] || ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"

# asdf
if [ ! -d "$HOME/.asdf" ]
then
  ln -s "$HOME/.dotfiles/submodules/asdf" "$HOME/.asdf"
fi
source "$HOME/.asdf/asdf.sh"

# envs
function pullenvs() {
  pyenv update
  git -C "$(nodenv root)/plugins/node-build" pull
  git -C "$HOME/.rbenv/plugins/ruby-build" pull
  git -C "$HOME/.dotfiles/submodules/goenv" pull
}

# direnv
which direnv >/dev/null || bash "$HOME/.dotfiles/submodules/direnv/install.sh"
eval "$(direnv hook zsh)"

# pyenv
export PYENV_ROOT="$HOME/.dotfiles/submodules/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export VIRTUAL_ENV_DISABLE_PROMPT="true"
[[ -e "$(pyenv root)/plugins/pyenv-update" ]] || (
  git clone "https://github.com/pyenv/pyenv-update.git" $(pyenv root)/plugins/pyenv-update
)

# rbenv
eval "$($HOME/.dotfiles/submodules/rbenv/bin/rbenv init -)"
[[ -e "$HOME/.rbenv/plugins/ruby-build" ]] || (
  mkdir -p "$HOME/.rbenv/plugins/ruby-build"
  git clone "https://github.com/rbenv/ruby-build.git" "$HOME/.rbenv/plugins/ruby-build"
)

# nodenv
export PATH="$HOME/.dotfiles/submodules/nodenv/bin:$PATH"
eval "$(nodenv init -)"

if [ ! -d "$(nodenv root)/plugins/node-build" ]
then
  git clone "https://github.com/nodenv/node-build.git" "$(nodenv root)/plugins/node-build"
fi

# goenv
export GOENV_ROOT="$HOME/.dotfiles/submodules/goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

# tfenv
export PATH="$HOME/.dotfiles/submodules/tfenv/bin:$PATH"

# jenv
export PATH="$HOME/.dotfiles/submodules/jenv/bin:$PATH"
eval "$(jenv init -)"

which java >/dev/null || (
  sudo apt update
  sudo apt install -y openjdk-17-jdk
  jenv add "$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")"
)

# rust
[[ -e "$HOME/.cargo" ]] || curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"

# gh
which gh >/dev/null || (
  # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y
)

# kubectl
which kubectl >/dev/null && source <(kubectl completion zsh)

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
which kubectl-krew >/dev/null || (
  # https://krew.sigs.k8s.io/docs/user-guide/setup/install/
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# helm
which helm >/dev/null || (
  tmpdir="$(mktemp -d)"
  curl -fsSL -o "$tmpdir/get_helm.sh" "https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
  chmod 700 "$tmpdir/get_helm.sh"
  "$tmpdir/get_helm.sh"
)
source <(helm completion zsh)

# kustomize
which kustomize >/dev/null || (
  cd "$HOME/.local/bin"
  curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
)

# minikube
which minikube >/dev/null || (
  cd "$(mktemp -d)"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
)

# https://github.com/sh0rez/kubectl-neat-diff
which kubectl-neat-diff >/dev/null || (
  cd "$HOME/.dotfiles/submodules/kubectl-neat-diff"
  which go >/dev/null && make install
)

export KUBECTL_EXTERNAL_DIFF=kubectl-neat-diff

source "$HOME/.dotfiles/submodules/kube-ps1/kube-ps1.sh"
export KUBE_PS1_PREFIX=""
export KUBE_PS1_SUFFIX=""
export KUBE_PS1_SYMBOL_PADDING=false
export KUBE_PS1_SEPARATOR=":"
export KUBE_PS1_SYMBOL_COLOR="cyan"
export KUBE_PS1_CTX_COLOR="cyan"
function kube_ps1_cluster_function() {
  echo "$1" | awk -F'/' '{print $NF}'
}
export KUBE_PS1_CLUSTER_FUNCTION="kube_ps1_cluster_function"

which stern >/dev/null 2>&1 && source <(stern --completion=zsh)

# compile
if [[ "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]
then
   zcompile "$HOME/.zshrc"
fi

# files
find "$HOME/.dotfiles/zsh.d" -name '*.zsh' |
while read f
do
  source $f
done

export PATH="$PATH:/opt/apache-maven-3.6.3/bin:/opt/gradle-6.7/bin"
