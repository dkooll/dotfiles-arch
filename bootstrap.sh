#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dkooll/dotfiles-arch.git"
TARGET_DIR="$HOME/workspaces/dkooll/dotfiles-arch"

echo "[bootstrap] using repo: $REPO_URL"
echo "[bootstrap] target dir: $TARGET_DIR"

# Zorg dat we op Arch zitten
if ! command -v pacman >/dev/null 2>&1; then
  echo "[bootstrap] ERROR: dit script is bedoeld voor Arch Linux (pacman)."
  exit 1
fi

# Minimaal: git (en optioneel zsh) installeren
if ! command -v git >/dev/null 2>&1; then
  echo "[bootstrap] installing git via pacman"
  sudo pacman -Syu --needed --noconfirm git
fi

# (optioneel) zsh installeren, maar GEEN chsh doen
if ! command -v zsh >/dev/null 2>&1; then
  echo "[bootstrap] installing zsh via pacman"
  sudo pacman -Syu --needed --noconfirm zsh
fi

mkdir -p "$(dirname "$TARGET_DIR")"

if [[ -d "$TARGET_DIR/.git" ]]; then
  echo "[bootstrap] repo already exists, pulling latest changes"
  git -C "$TARGET_DIR" pull --ff-only
else
  echo "[bootstrap] cloning repo"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

echo "[bootstrap] running install.sh"
bash "$TARGET_DIR/install.sh"

echo
echo "[bootstrap] done 🎉"
echo "Als je zsh als default shell wilt: 'chsh -s /usr/bin/zsh' en daarna 'exec zsh'."
