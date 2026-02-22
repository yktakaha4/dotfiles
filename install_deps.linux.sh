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
  gh \
  jq

which peco >/dev/null || (
  tmp_dir="$(mktemp -d)"
  arch="$(d_arch)"
  curl -fsSL "https://github.com/peco/peco/releases/download/v0.5.11/peco_linux_$arch.tar.gz" | tar -xz -C "$tmp_dir"
  mkdir -p "$HOME/.local/bin"
  mv -v "$tmp_dir/peco_linux_$arch/peco" "$HOME/.local/bin/peco"
)

if [ -n "$DOTFILES_INSTALL_DEV" ]; then
  $INSTALL_CMD shellcheck curl
  which shellspec >/dev/null || (
    curl -fsSL https://git.io/shellspec | sh -s -- --yes
  )
fi
