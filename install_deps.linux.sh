base_dir="$(cd "$(dirname "$0")" || exit; pwd)"

. "$base_dir/.helper.sh"

if d_require apt; then
  echo "Detected apt package manager."
  UPDATE_CMD="sudo apt update"
  INSTALL_CMD="sudo apt install -y"
elif d_require dnf; then
  echo "Detected dnf package manager."
  UPDATE_CMD="sudo dnf check-update"
  INSTALL_CMD="sudo dnf install -y"
elif d_require yum; then
  echo "Detected yum package manager."
  UPDATE_CMD="sudo yum check-update"
  INSTALL_CMD="sudo yum install -y"
else
  echo "package manager not found..."
  exit 1
fi

echo "Updating package lists..."
$UPDATE_CMD

echo "Installing dependencies..."
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
