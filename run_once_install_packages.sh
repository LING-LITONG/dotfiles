#!/bin/bash
# chezmoi run_once script — install packages and tools on a new machine
set -e

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "oh-my-zsh already installed"
    return
  fi
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

install_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$zsh_custom/plugins"

  # zsh-autosuggestions
  if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
  fi

  # zsh-syntax-highlighting
  if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
  fi

  # fzf-tab
  if [[ ! -d "$zsh_custom/plugins/fzf-tab" ]]; then
    git clone https://github.com/Aloxaf/fzf-tab "$zsh_custom/plugins/fzf-tab"
  fi

  # powerlevel10k
  if [[ ! -d "$zsh_custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k "$zsh_custom/themes/powerlevel10k"
  fi
}

install_fzf() {
  if command -v fzf &>/dev/null; then
    echo "fzf already installed"
    return
  fi
  if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all --no-bash
  fi
}

install_tools_apt() {
  # root 不需要 sudo，普通用户无密码 sudo，否则跳过
  local SUDO=""
  if [[ "$(id -u)" -ne 0 ]]; then
    if sudo -n true 2>/dev/null; then
      SUDO="sudo -n"
    else
      echo "sudo requires a password — skipping apt packages, install manually:"
      echo "  sudo apt-get install -y tmux ripgrep fd-find bat tree htop jq xclip"
      return 0
    fi
  fi
  $SUDO apt-get update -qq
  $SUDO apt-get install -y -qq \
    tmux \
    fzf \
    ripgrep \
    fd-find \
    bat \
    tree \
    htop \
    unzip \
    wget \
    curl \
    jq \
    xclip \
    language-pack-zh-hans \
    2>/dev/null || true

  # fd symlink (apt package is called fdfind)
  mkdir -p "$HOME/.local/bin"
  [[ -f "$HOME/.local/bin/fd" ]] || ln -s "$(which fdfind)" "$HOME/.local/bin/fd" 2>/dev/null || true

  # bat symlink (apt package might be batcat)
  [[ -f "$HOME/.local/bin/bat" ]] || ln -s "$(which batcat)" "$HOME/.local/bin/bat" 2>/dev/null || true
}

install_lazygit() {
  if command -v lazygit &>/dev/null; then
    echo "lazygit already installed"
    return
  fi
  local version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  mkdir -p "$HOME/.local/bin"
  mv lazygit "$HOME/.local/bin/"
  rm lazygit.tar.gz
}

install_neovim() {
  if command -v nvim &>/dev/null; then
    echo "neovim already installed"
    return
  fi
  # Use appimage or download prebuilt
  curl -Lo nvim.tar.gz "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
  tar xf nvim.tar.gz
  mkdir -p "$HOME/.local"
  cp -r nvim-linux-x86_64/* "$HOME/.local/"
  rm -rf nvim-linux-x86_64 nvim.tar.gz
}

# Main
echo "=== Setting up new machine ==="

install_oh_my_zsh
install_zsh_plugins
install_fzf
install_neovim

if command -v apt-get &>/dev/null; then
  install_tools_apt
elif command -v brew &>/dev/null; then
  echo "Homebrew detected, install packages manually or via Brewfile"
elif command -v pacman &>/dev/null; then
  echo "Arch detected, install packages manually or via pacman"
fi

install_lazygit

echo "=== Setup complete ==="
echo "Run: chsh -s $(which zsh)    # to change default shell"
echo "Run: p10k configure          # to re-run powerlevel10k wizard"
