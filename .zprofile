export DOTFILES_ZPROFILE_LOADED=1

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

source "$HOME/.dotfiles/.helper.sh"

if d_debug; then
  set -x
  zmodload zsh/zprof && zprof
fi

if d_exists "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"; then
  source "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"
fi
