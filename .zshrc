# options

setopt histignorealldups sharehistory prompt_subst ignoreeof auto_cd auto_pushd pushd_ignore_dups no_flow_control
bindkey -e

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# env
export PATH="$HOME/.dotfiles/bin:$PATH"
export EDITOR="vim"
export PAGER="less"

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
HISTSIZE="10000"
SAVEHIST="10000"
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

alias open='xdg-open'

which xclip > /dev/null || sudo apt-get install -y xclip
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'
alias pbvim="pbpaste | pvim | pbcopy"

alias colorpallet='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done'
alias viminstall="vim +PluginInstall +qall"

alias dcu='docker-compose up -d --remove-orphans'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f --tail=10'
alias dcp='docker-compose ps'
alias dcx='docker-compose exec'
alias dcr='docker-compose restart'
function dcul() {
  dcu $@ && dcl
}

alias k='kubectl'
alias kgpo='kubectl get po -o wide'
alias kgno='kubectl get no -o wide'
alias k9s='k9s --readonly'
alias k9sw='\k9s'

alias editorconfig="cat $HOME/.dotfiles/.editorconfig"
alias makefile="cat $HOME/.dotfiles/.Makefile"

alias tailf="tail -f"
alias open="xdg-open"
alias hdiff="$HOME/.dotfiles/submodules/diff2html-cli/bin/diff2html -i stdin"

alias ssh="ssh -o ServerAliveInterval=60"

alias qcsv='q -b -d, -HO'

alias iam='aws sts get-caller-identity --query Arn --output text'

# rcfiles and configs

# git
[[ -e "$HOME/.gitconfig" ]] || ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
[[ -e "$HOME/.gitignore_global" ]] || ln -s "$HOME/.dotfiles/.gitignore_global" "$HOME/.gitignore_global"

# vim
[[ -e "$HOME/.vimrc" ]] || ln -s "$HOME/.dotfiles/.vimrc" "$HOME/.vimrc"
if [[ ! -e "$HOME/.vim/bundle/Vundle.vim" ]]
then
  ln -s "$HOME/.dotfiles/submodules/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim"
  vim +PluginInstall +qall
fi

# xinput
[[ -f "$HOME/.xmodmap" ]] || ln -s "$HOME/.dotfiles/.xmodmap" "$HOME/.xmodmap"
[[ -f "$HOME/.xinputrc" ]] || ln -s "$HOME/.dotfiles/.xinputrc" "$HOME/.xinputrc"

# diff
[[ -e "$HOME/.dotfiles/submodules/diff2html-cli/node_modules" ]] || (
  cd "$HOME/.dotfiles/submodules/diff2html-cli"
  yarn build
)

# envs

which curl >/dev/null || sudo apt-get install -y curl
which tmux >/dev/null || sudo apt-get install -y tmux

# tmux
[[ -f "$HOME/.tmux.conf" ]] || ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"

# direnv
which direnv >/dev/null || bash "$HOME/.dotfiles/submodules/direnv/install.sh"
eval "$(direnv hook zsh)"

# pyenv
export PYENV_ROOT="$HOME/.dotfiles/submodules/pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export VIRTUAL_ENV_DISABLE_PROMPT="true"

# rbenv
eval "$(rbenv init -)"
[[ -e "$HOME/.rbenv/plugins/ruby-build" ]] || (
  mkdir -p "$HOME/.rbenv/plugins/ruby-build"
  git clone "https://github.com/rbenv/ruby-build.git" "$HOME/.rbenv/plugins/ruby-build"
)

# pipenv
export PIPENV_VENV_IN_PROJECT="true"

# poetry
pyenv which poetry > /dev/null 2>&1 && (
  poetry config virtualenvs.in-project true
)

# nodenv
export PATH="$HOME/.dotfiles/submodules/nodenv/bin:$PATH"
eval "$(nodenv init -)"

export NODETOOLS_PATH="$HOME/.dotfiles/scripts/nodetools"
[[ -e "$NODETOOLS_PATH/node_modules" ]] || (
  cd "$NODETOOLS_PATH"
  npm ci >/dev/null
)

# gvm
[[ -e "$HOME/.gvm" ]] || zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source "$HOME/.gvm/scripts/gvm"

# tfenv
export PATH="$HOME/.dotfiles/submodules/tfenv/bin:$PATH"

# jenv
export PATH="$HOME/.dotfiles/submodules/jenv/bin:$PATH"
eval "$(jenv init -)"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubectl
source <(kubectl completion zsh)

# heml
source <(helm completion zsh)

# https://github.com/sh0rez/kubectl-neat-diff
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

# flyctl
export FLYCTL_INSTALL="/home/tkhs/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

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
