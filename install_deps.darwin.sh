eval "$(/opt/homebrew/bin/brew shellenv)"

brew install \
  git \
  tmux \
  gh \
  jq \
  peco

if [ -n "$DOTFILES_INSTALL_DEV" ]; then
  brew install shellspec shellcheck
fi
