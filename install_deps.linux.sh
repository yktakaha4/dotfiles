base_dir="$(cd "$(dirname "$0")" || exit; pwd)"

. "$base_dir/.helper.sh"

if d_require apt; then
  INSTALL_CMD="sudo apt install -y"
elif d_require dnf; then
  INSTALL_CMD="sudo dnf install -y"
elif d_require yum; then
  INSTALL_CMD="sudo yum install -y"
else
  echo "package manager not found..."
  exit 1
fi

$INSTALL_CMD \
  zsh \
  git \
  tmux \
  gh

if [ -n "$DOTFILES_INSTALL_DEV" ]; then
  $INSTALL_CMD shellcheck curl
  which shellspec >/dev/null || (
    curl -fsSL https://git.io/shellspec | sh -s -- --yes
  )
fi
