# options

setopt histignorealldups sharehistory prompt_subst ignoreeof auto_cd auto_pushd pushd_ignore_dups no_flow_control

# env
export EDITOR="vim"
export PAGER="less"

# Set up the prompt

autoload -Uz promptinit && promptinit
autoload -Uz colors && colors
autoload -Uz vcs_info

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "!"
zstyle ':vcs_info:git:*' unstagedstr "+"
zstyle ':vcs_info:*' formats " %c%u%b"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

function precmd() { vcs_info }

PROMPT='
%F{blue}%~%f%F{008}$vcs_info_msg_0_%f%(?..%F{red} (%?%))%f %F{yellow}%*%f
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

# bindkeys
stty erase ^H
bindkey "^[[3~" delete-char

# alias
alias ls='ls --color'
alias ll='ls -l'
alias la='ls -la'
alias l='ll'

alias less='less -R'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias .='source'

which xclip > /dev/null || sudo apt-get install -y xclip
alias pbcopy='xclip -selection c'
alias pbpaste='xclip -selection c -o'

alias colorpallet='for c in {000..255}; do echo -n "\e[38;5;${c}m $c" ; [ $(($c%16)) -eq 15 ] && echo;done'

# rcfiles and configs
[[ -e "$HOME/.gitconfig" ]] || ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
[[ -e "$HOME/.vimrc" ]] || ln -s "$HOME/.dotfiles/.vimrc" "$HOME/.vimrc"

# envs

which curl >/dev/null || sudo apt-get install -y curl

# direnv
which direnv >/dev/null || curl -sfL https://direnv.net/install.sh | bash
eval "$(direnv hook zsh)"

# pyenv
[[ -e "$HOME/.pyenv" ]] || git clone "https://github.com/pyenv/pyenv.git" "$HOME/.pyenv"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pipenv
export PIPENV_VENV_IN_PROJECT="true"

# nodenv
[[ -e "$HOME/.nodenv" ]] || git clone "https://github.com/nodenv/nodenv.git" "$HOME/.nodenv"
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# gvm
[[ -e "$HOME/.gvm" ]] || zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source "$HOME/.gvm/scripts/gvm"

# tfenv
[[ -e "$HOME/.tfenv" ]] || git clone https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
export PATH="$HOME/.tfenv/bin:$PATH"

# jenv
[[ -e "$HOME/.jenv" ]] || git clone "https://github.com/jenv/jenv.git" "$HOME/.jenv"
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# compile
if [[ "$HOME/.zshrc" -nt "$HOME/.zshrc.zwc" ]]
then
   zcompile "$HOME/.zshrc"
fi
