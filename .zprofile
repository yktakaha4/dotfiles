. "$HOME/.dotfiles/.helper.sh"

if d_debug; then
  set -x
  zmodload zsh/zprof && zprof
fi

if d_exists "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"; then
  . "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"
fi
