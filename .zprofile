# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"

export DOTFILES_ZPROFILE_LOADED=1

source "$HOME/.dotfiles/.helper.sh"

if d_debug; then
  set -x
  zmodload zsh/zprof && zprof
fi

if d_exists "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"; then
  source "$DOTFILES_BASE_PATH/.zprofile.$(d_os)"
fi

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
