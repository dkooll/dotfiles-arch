#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dkooll/dotfiles-arch.git"
TARGET_DIR="$HOME/workspaces/dkooll/dotfiles-arch"

echo "using repo: $REPO_URL"
echo "target dir: $TARGET_DIR"

if ! command -v pacman >/dev/null 2>&1; then
  echo "ERROR: arch linux pacman should be available"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "installing git via pacman"
  sudo pacman -Syu --needed --noconfirm git
fi

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "repo already exists, pulling latest changes"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "cloning repo"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

echo "running install.sh"
bash "$TARGET_DIR/install.sh"

echo
echo "done"
echo "set default zsh by doing: 'chsh -s /usr/bin/zsh'"
