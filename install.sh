#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${TARGET_DIR:-$HOME/workspaces/dkooll/dotfiles-arch}"

log() {
  printf "%s\n" "$*"
}

install_source() {
  local name=$1
  local check=$2
  local cmd=$3

  if eval "$check" &>/dev/null; then
    log "$name already installed"
    return
  fi

  log "installing $name"
  eval "$cmd"
}

install_packages() {
  log "installing base packages via pacman"

  sudo pacman -Syu --needed --noconfirm \
    base-devel \
    cmake \
    gcc \
    curl wget unzip \
    git \
    tmux \
    ripgrep \
    fd \
    fzf \
    less \
    python python-pip \
    ansible \
    github-cli \
    azure-cli \
    gopls \
    lua-language-server \
    pyright \
    rust-analyzer \
    bash-language-server

  install_source "neovim" "command -v nvim" \
    "wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -O /tmp/nvim.tar.gz \
     && sudo rm -rf /opt/nvim-linux-x86_64 \
     && sudo tar -xzf /tmp/nvim.tar.gz -C /opt \
     && sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
     && rm /tmp/nvim.tar.gz"

  install_source "eza" "command -v eza" \
    "wget -q https://github.com/eza-community/eza/releases/latest/download/eza_\$(uname -m)-unknown-linux-gnu.tar.gz -O /tmp/eza.tar.gz \
     && tar -xzf /tmp/eza.tar.gz -C /tmp \
     && sudo mv /tmp/eza /usr/local/bin/ \
     && rm /tmp/eza.tar.gz"

  install_source "tfenv" "test -d \$HOME/.tfenv" \
    "git clone --depth=1 https://github.com/tfutils/tfenv.git \$HOME/.tfenv \
     && mkdir -p \$HOME/.local/bin \
     && ln -sf \$HOME/.tfenv/bin/tfenv \$HOME/.local/bin/tfenv \
     && ln -sf \$HOME/.tfenv/bin/terraform \$HOME/.local/bin/terraform"

  if [[ -f "$HOME/.local/bin/tfenv" ]]; then
    if ! "$HOME/.local/bin/tfenv" list 2>/dev/null | grep -qE '^[0-9]'; then
      log "installing terraform via tfenv"
      "$HOME/.local/bin/tfenv" install latest
      "$HOME/.local/bin/tfenv" use latest
    fi
  fi

  local tfls_arch
  case "$(uname -m)" in
    x86_64|amd64) tfls_arch=amd64 ;;
    arm64|aarch64) tfls_arch=arm64 ;;
    *) tfls_arch=amd64 ;;
  esac

  mkdir -p "$HOME/.local/bin"

  install_source "terraform-ls 0.38.2" "command -v terraform-ls >/dev/null && terraform-ls version 2>/dev/null | grep -q '0.38.2'" \
    "TFLS_VERSION=0.38.2 \
     && wget -q https://releases.hashicorp.com/terraform-ls/\${TFLS_VERSION}/terraform-ls_\${TFLS_VERSION}_linux_${tfls_arch}.zip -O /tmp/terraform-ls.zip \
     && unzip -o /tmp/terraform-ls.zip -d /tmp \
     && mv /tmp/terraform-ls \$HOME/.local/bin/terraform-ls \
     && chmod +x \$HOME/.local/bin/terraform-ls \
     && rm /tmp/terraform-ls.zip"

  local go_arch
  case "$(uname -m)" in
    x86_64|amd64) go_arch=amd64 ;;
    arm64|aarch64) go_arch=arm64 ;;
    *) go_arch=amd64 ;;
  esac

  install_source "go" "test -d /usr/local/go" \
    "wget -q https://go.dev/dl/\$(curl -s https://go.dev/VERSION?m=text | head -n1).linux-${go_arch}.tar.gz -O /tmp/go.tar.gz \
     && sudo rm -rf /usr/local/go \
     && sudo tar -C /usr/local -xzf /tmp/go.tar.gz \
     && rm /tmp/go.tar.gz"

  [[ -x /usr/local/go/bin/go ]] && sudo ln -sf /usr/local/go/bin/go /usr/local/bin/go

  install_source "rust" "command -v rustc" \
    "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable"

  [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

  install_source "fnm" "command -v fnm" \
    "curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell"

  export FNM_DIR="$HOME/.local/share/fnm"
  if [[ -d "$FNM_DIR" ]]; then
    export PATH="$FNM_DIR:$PATH"
    eval "$(fnm env)"

    if ! fnm list 2>/dev/null | grep -q 'v22'; then
      log 'installing node 22 via fnm'
      fnm install 22
      fnm default 22
    fi
  fi

  if [[ -d "$FNM_DIR" ]] && command -v fnm &>/dev/null; then
    eval "$(fnm env)"
    fnm use 22 || true
    npm install -g --silent neovim @anthropic-ai/claude-code @openai/codex vscode-langservers-extracted || true
  fi

  local zsh_path
  zsh_path=$(command -v zsh || true)
  if [[ -n "$zsh_path" ]] && ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi
}

setup_symlinks() {
  log "setting up symlinks"

  mkdir -p "$HOME/.config"

  for pair in \
    ".zshrc:.zshrc" \
    ".tmux.conf:.tmux.conf" \
    "nvim:.config/nvim" \
    "ansible.cfg:.ansible.cfg"
  do
    local src="$TARGET_DIR/${pair%%:*}"
    local dest="$HOME/${pair##*:}"

    [[ ! -e "$src" ]] && continue

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
      log "backing up $dest -> $dest.backup"
      mv "$dest" "$dest.backup"
    fi

    log "linking $src -> $dest"
    ln -sf "$src" "$dest"
  done
}

setup_tmux() {
  log "ensuring tmux plugin manager (tpm) is installed"

  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone -q https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
}

main() {
  install_packages
  setup_tmux
  setup_symlinks
  log "done"
}

main
